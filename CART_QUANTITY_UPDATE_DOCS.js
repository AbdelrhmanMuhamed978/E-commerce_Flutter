// Cart Quantity Update Implementation
// =====================================

/* 
API Endpoint: PATCH /cart/:productId
Payload: { "quantity": newQuantity }

Examples:
=========

1. Increment Product Quantity:
   - User has product with quantity: 1
   - User clicks "+" button
   - App calculates: 1 + 1 = 2
   - API Call: PATCH /cart/60f7b3b3b3b3b3b3b3b3b3b3
   - Payload: { "quantity": 2 }

2. Decrement Product Quantity:
   - User has product with quantity: 3
   - User clicks "-" button  
   - App calculates: 3 - 1 = 2
   - API Call: PATCH /cart/60f7b3b3b3b3b3b3b3b3b3b3
   - Payload: { "quantity": 2 }

3. Decrement to Zero (Remove Item):
   - User has product with quantity: 1
   - User clicks "-" button
   - App calculates: 1 - 1 = 0
   - Instead of PATCH, calls DELETE to remove item

Implementation Flow:
==================

CartScreen UI:
- "+" button → calls cartProvider.incrementQuantity(productId)
- "-" button → calls cartProvider.decrementQuantity(productId)

CartProvider Methods:
- incrementQuantity() → finds current quantity, adds 1, calls updateCartItem()
- decrementQuantity() → finds current quantity, subtracts 1, calls updateCartItem() or removeFromCart() if ≤ 0
- updateCartItem() → calls API service with PATCH request

ApiService:
- updateCartItem() → PATCH /cart/${productId} with { "quantity": newQuantity }

Full URL Examples:
=================
https://e-commerce-mean-production.up.railway.app/api/v1/cart/60f7b3b3b3b3b3b3b3b3b3b3

Authentication:
==============
Headers: { "Authorization": "Bearer <jwt_token>" }
*/
