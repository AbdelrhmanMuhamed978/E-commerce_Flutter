# E-Commerce Flutter Mobile App

A comprehensive Flutter mobile application that mirrors your MEAN stack e-commerce website functionality. This app provides a complete shopping experience with user authentication, product browsing, cart management, order processing, and admin capabilities.

## Features

### 🔐 Authentication
- User registration and login
- JWT-based authentication
- Persistent sessions with SharedPreferences
- Role-based access control (User/Admin)

### 🛍️ Product Management
- Product listing with search and filtering
- Category-based navigation
- Product detail views with image galleries
- Product ratings and reviews display
- Real-time stock status

### 🛒 Shopping Cart
- Add/remove items from cart
- Quantity management
- Real-time price calculations
- Persistent cart data
- Cart badge with item count

### 📦 Order Management
- Comprehensive checkout process
- Multiple payment method support
- Order confirmation and tracking
- Order history with detailed views
- Order status updates

### 👤 User Profile
- Profile management and editing
- Order history access
- Account settings
- User avatar support

### 🔧 Admin Dashboard
- User management and oversight
- Order management and status updates
- Real-time analytics
- Email notifications to customers
- Print order functionality

### 🎨 UI/UX Features
- Material Design principles
- Responsive design for all screen sizes
- Smooth animations and transitions
- Loading states and error handling
- Pull-to-refresh functionality
- Image caching and optimization

## Technical Stack

- **Flutter** 3.0+
- **Dart** 3.0+
- **Provider** for state management
- **HTTP** for API communication
- **SharedPreferences** for local storage
- **CachedNetworkImage** for image optimization
- **Intl** for internationalization

## Project Structure

```
lib/
├── core/
│   ├── app.dart                 # Main app configuration
│   ├── models/                  # Data models
│   │   ├── user_model.dart
│   │   └── product_model.dart
│   ├── providers/               # State management
│   │   ├── auth_provider.dart
│   │   ├── cart_provider.dart
│   │   └── product_provider.dart
│   └── services/                # API services
│       └── api_service.dart
├── screens/                     # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── product/
│   │   └── product_detail_screen.dart
│   ├── cart/
│   │   └── cart_screen.dart
│   ├── checkout/
│   │   └── checkout_screen.dart
│   ├── orders/
│   │   └── orders_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   ├── admin/
│   │   └── admin_dashboard.dart
│   └── splash_screen.dart
└── main.dart                    # App entry point
```

## API Integration

The app integrates with your existing MEAN stack backend API:
- **Base URL**: `https://abdelrhman-dev.me/api`
- **Authentication**: JWT Bearer tokens
- **Endpoints**: Users, Products, Cart, Orders

### Supported API Endpoints:
- `POST /users/login` - User authentication
- `POST /users/register` - User registration
- `GET /products` - Fetch all products
- `GET /products/:id` - Get product details
- `POST /cart` - Add item to cart
- `GET /cart` - Get cart items
- `POST /orders` - Create new order
- `GET /orders/myorders` - Get user orders

## Setup Instructions

### Prerequisites
- Flutter SDK 3.0 or higher
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd E-commerce-Flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add assets**
   - Place your logo in `assets/images/logo.png`
   - Add any additional images to `assets/images/`

4. **Update API configuration**
   - Verify the base URL in `lib/core/services/api_service.dart`
   - Ensure your backend API is running

5. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### Environment Setup
- **Development**: Uses `https://abdelrhman-dev.me/api`
- **Production**: Update base URL in `api_service.dart`

### Authentication
The app supports the same credentials as your web application:
- **Regular User**: `apdo@apdo.com` / `0123456789`
- **Admin User**: `admin@ceo.apdo` / `123456789`

## Features Roadmap

### ✅ Completed
- [x] User authentication and registration
- [x] Product listing and search
- [x] Shopping cart functionality
- [x] Order management
- [x] User profile management
- [x] Admin dashboard
- [x] Responsive design

### 🚧 In Progress
- [ ] Push notifications
- [ ] Offline support
- [ ] Advanced filtering
- [ ] Wishlist functionality

### 📋 Planned
- [ ] Social media login
- [ ] Multiple language support
- [ ] Advanced analytics
- [ ] Product reviews and ratings
- [ ] Live chat support

## Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Test Credentials
Use the same test accounts as your web application:
- Regular user: `apdo@apdo.com` / `0123456789`
- Admin user: `admin@ceo.apdo` / `123456789`

## Deployment

### Android
1. Build APK: `flutter build apk`
2. Build App Bundle: `flutter build appbundle`

### iOS
1. Build iOS: `flutter build ios`
2. Archive in Xcode for App Store

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Support

For support or questions:
- Create an issue in the repository
- Contact: [Your contact information]

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built to complement the MEAN stack e-commerce website
- Designed with Material Design principles
- Optimized for performance and user experience

---

**Note**: This Flutter app is designed to work seamlessly with your existing MEAN stack backend. Ensure your API server is running and accessible for full functionality.
