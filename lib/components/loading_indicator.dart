import 'package:flutter/material.dart';

loadingGifIndicator({required String gif, required String message}) {
  return Container(
    alignment: Alignment.center,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(gif, height: 100,),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  ); 
}