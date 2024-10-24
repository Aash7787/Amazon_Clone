import 'dart:convert';
import 'dart:io';
import 'dart:developer'; // Import the log function for debugging

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amazon_clone/common/err/error_handling.dart';
import 'package:flutter_amazon_clone/constants/global_variables.dart';
import 'package:flutter_amazon_clone/constants/utils.dart';
import 'package:flutter_amazon_clone/features/admin/controller/bloc/admin_bloc.dart';
import 'package:flutter_amazon_clone/features/admin/model/product.dart';
import 'package:flutter_amazon_clone/features/auth/providers/user_auth_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class AdminService {
  Future<void> sellProduct({
    required BuildContext context,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    required List<File> images,
  }) async {
    final userProvider = context.read<UserAuthProvider>();
    final cloudinary = CloudinaryPublic('dctxcupgb', 'pabqfkte');

    try {
      List<String> imageUrls = [];

      log('Starting image upload'); // Add a log for debugging

      // Upload all images to Cloudinary in parallel
      for (var image in images) {
        log('Uploading image: ${image.path}'); // Log each image upload
        final uploadResponse = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path, folder: name),
        );
        imageUrls.add(uploadResponse.secureUrl);
        log('Image uploaded, URL: ${uploadResponse.secureUrl}'); // Log successful upload
      }

      log('All images uploaded, preparing product object'); // Log after images are uploaded

      // After all images are uploaded, create the product object
      Product product = Product(
        name: name,
        description: description,
        price: price,
        quantity: quantity,
        category: category,
        images: imageUrls, // Set the uploaded image URLs
      );

      log('Sending product data to server: ${product.toJson()}'); // Log the product data

      // Make the POST request to your server
      var response = await http.post(
        Uri.parse('$uri/admin/add-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          xToken: userProvider.user.token,
        },
        body: product.toJson(), // Convert product to JSON
      );

      log('Received response with status code: ${response.statusCode}'); // Log the status code

      // Handle HTTP error response
      httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () async {
          log('Product added successfully'); // Log success
          showSnackBar(context, 'Product added successfully');

          context.read<AdminBloc>().images.clear();
          await Future.delayed(const Duration(seconds: 1),
              () => Navigator.pop(context)); // Close the screen on success
        },
      );
    } catch (e) {
      log('Error occurred: $e'); // Log any caught error
      // Show error message if an exception occurs
      showSnackBar(context, e.toString());
    }
  }

  Future<List<Product>> fetchAllProducts(BuildContext context) async {
    final userProvider = context.read<UserAuthProvider>();
    List<Product> productList = [];
    try {
      var response = await http.get(
        Uri.parse('$uri/admin/get-products'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          xToken: userProvider.user.token,
        },
      );
      httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () {
          for (var i = 0; i < jsonDecode(response.body).length; i++) {
            productList.add(
              Product.fromJson(
                jsonEncode(
                  jsonDecode(response.body)[i],
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return productList;
  }

  void deleteProduct(
      {required BuildContext context,
      required Product product,
      required VoidCallback onSuccess}) async {
    final userProvider = context.read<UserAuthProvider>();

    try {
      // Make the POST request to your server
      var response = await http.post(
        Uri.parse('$uri/admin/delete-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          xToken: userProvider.user.token,
        },
        body: jsonEncode({'id': product.id}), // Convert product to JSON
      );

      log('Received response with status code: ${response.statusCode}'); // Log the status code

      // Handle HTTP error response
      httpErrorHandle(
        response: response,
        context: context,
        onSuccess: () async {
          showSnackBar(context, 'Deleted');
          onSuccess();

          // Close the screen on success
        },
      );
    } catch (e) {
      log('Error occurred: $e'); // Log any caught error
      // Show error message if an exception occurs
      showSnackBar(context, e.toString());
    }
  }
}
