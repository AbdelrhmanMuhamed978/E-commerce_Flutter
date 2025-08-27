import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  // Users data
  List<dynamic> _users = [];
  bool _usersLoading = false;
  String? _usersError;

  // Orders data
  List<dynamic> _orders = [];
  bool _ordersLoading = false;
  String? _ordersError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAdminAccess();
    _loadUsersData();
    _loadOrdersData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkAdminAccess() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied: Admin privileges required'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  Future<void> _loadUsersData() async {
    setState(() {
      _usersLoading = true;
      _usersError = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Set the JWT token for authenticated requests
      _apiService.setToken(authProvider.token ?? '');

      // Get all users from your backend using the admin userType ID
      final users =
          await _apiService.getAllUsers(authProvider.user?.userType ?? '');

      setState(() {
        _users = users;
        _usersLoading = false;
      });
    } catch (e) {
      setState(() {
        _usersError = e.toString();
        _usersLoading = false;
      });
    }
  }

  Future<void> _loadOrdersData() async {
    setState(() {
      _ordersLoading = true;
      _ordersError = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Set the JWT token for authenticated requests
      _apiService.setToken(authProvider.token ?? '');

      // Get customer orders from your backend
      final orders = await _apiService.getCustomersOrders();

      setState(() {
        _orders = orders;
        _ordersLoading = false;
      });
    } catch (e) {
      setState(() {
        _ordersError = 'Failed to load orders: ${e.toString()}';
        _ordersLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.shopping_bag), text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_usersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_usersError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading users',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _usersError!,
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsersData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text('No users found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsersData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: _buildUserAvatar(user),
              title: Text(
                user['name'] ?? 'Unknown User',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email'] ?? 'No email'),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _isAdmin(user)
                          ? Colors.orange[100]
                          : Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isAdmin(user) ? 'ADMIN' : 'USER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _isAdmin(user)
                            ? Colors.orange[800]
                            : Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      _showUserDetails(user);
                      break;
                    case 'edit':
                      _editUser(user);
                      break;
                    case 'delete':
                      _deleteUser(user);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 18),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit User'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete User',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (_ordersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_ordersError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading orders',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _ordersError!,
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrdersData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Text('No orders found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrdersData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return AdminOrderCard(
            order: order,
            onStatusChanged: (newStatus) {
              _updateOrderStatus(order['id'], newStatus);
            },
          );
        },
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user['name'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Email: ${user['email'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Role: ${user['role'] ?? 'user'}'),
            const SizedBox(height: 8),
            Text('Created: ${_formatDate(user['createdAt'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    // TODO: Implement user editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User editing coming soon')),
    );
  }

  void _deleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement user deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deletion coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(dynamic orderId, String newStatus) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _apiService.setToken(authProvider.token ?? '');

      // Update order status via API
      await _apiService.updateOrderStatus(orderId, newStatus);

      // Update the local order data
      setState(() {
        final orderIndex =
            _orders.indexWhere((order) => order['id'] == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex]['status'] = newStatus;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Helper method to check if user is admin
  bool _isAdmin(Map<String, dynamic> user) {
    return user['userType'] == '68486185d89a99ebb571c241';
  }

  // Helper method to build user avatar
  Widget _buildUserAvatar(Map<String, dynamic> user) {
    final avatar = user['avatar'];
    final name = user['name'] ?? 'U';
    final isAdmin = _isAdmin(user);

    if (avatar != null && avatar.isNotEmpty) {
      String imageUrl;

      // Check if it's a local uploaded avatar (filename without http)
      if (!avatar.startsWith('http')) {
        // It's a filename from local upload, construct the full URL using /avatars/ path
        imageUrl =
            'https://e-commerce-mean-production.up.railway.app/api/v1/avatars/$avatar';
      } else {
        // It's a Google/external URL (OAuth), use directly
        imageUrl = avatar;
      }

      return CircleAvatar(
        backgroundColor: isAdmin ? Colors.orange[100] : Colors.blue[100],
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isAdmin ? Colors.orange : Colors.blue,
              ),
            ),
            errorWidget: (context, url, error) => Text(
              name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isAdmin ? Colors.orange : Colors.blue,
              ),
            ),
          ),
        ),
      );
    }

    // No avatar, show initial
    return CircleAvatar(
      backgroundColor: isAdmin ? Colors.orange[100] : Colors.blue[100],
      child: Text(
        name.substring(0, 1).toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isAdmin ? Colors.orange : Colors.blue,
        ),
      ),
    );
  }
}

class AdminOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Function(String) onStatusChanged;

  const AdminOrderCard({
    Key? key,
    required this.order,
    required this.onStatusChanged,
  }) : super(key: key);

  String _formatPrice(dynamic price) {
    if (price == null) return '0.00';
    if (price is num) {
      return price.toStringAsFixed(2);
    } else if (price is String) {
      final parsedPrice = double.tryParse(price);
      return parsedPrice?.toStringAsFixed(2) ?? '0.00';
    }
    return '0.00';
  }

  double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is num) {
      return price.toDouble();
    } else if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final products = order['products'] as List? ?? [];
    final userName = order['name'] ?? 'Unknown User';
    final userEmail = order['email'] ?? '';
    final status = order['status'] ?? 'pending';

    // Calculate total price from products
    double total = 0.0;
    for (var product in products) {
      final price = _parsePrice(product['price']);
      final quantity = product['quantity'] ?? 0;
      total += price * quantity;
    }

    final orderDate =
        DateTime.parse(order['createdAt'] ?? DateTime.now().toIso8601String());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['id']?.toString().substring(0, 8) ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$userName • $userEmail',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm').format(orderDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: status,
                  onSelected: onStatusChanged,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'pending', child: Text('Pending')),
                    const PopupMenuItem(
                        value: 'processing', child: Text('Processing')),
                    const PopupMenuItem(
                        value: 'shipped', child: Text('Shipped')),
                    const PopupMenuItem(
                        value: 'delivered', child: Text('Delivered')),
                    const PopupMenuItem(
                        value: 'cancelled', child: Text('Cancelled')),
                  ],
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: _getStatusColor(status),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Products
            ...products.take(2).map<Widget>((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          color: Colors.white, // White background
                          child: product['image'] != null
                              ? CachedNetworkImage(
                                  imageUrl: product['image'],
                                  fit: BoxFit.contain, // Show full image
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, size: 20),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.image_not_supported,
                                    size: 20,
                                  ),
                                )
                              : const Icon(Icons.image_not_supported, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['title'] ?? 'Unknown Product',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Qty: ${product['quantity']} × \$${_formatPrice(product['price'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            if (products.length > 2)
              Text(
                '+ ${products.length - 2} more items',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),

            const SizedBox(height: 12),
            const Divider(),

            // Total and Actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total: \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.print, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Print functionality coming soon')),
                        );
                      },
                      tooltip: 'Print Order',
                    ),
                    IconButton(
                      icon: const Icon(Icons.email, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Email functionality coming soon')),
                        );
                      },
                      tooltip: 'Email Customer',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
