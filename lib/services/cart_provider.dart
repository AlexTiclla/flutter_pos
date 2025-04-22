import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  Cart? _cart;
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Cart? get cart => _cart;
  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);
  int get itemCount => _items.length;

  // Cargar el carrito del usuario
  Future<void> loadUserCart(int userId) async {
    _setLoading(true);
    _error = null;

    try {
      final cart = await _cartService.getUserCart(userId);
      _cart = cart;
      await _loadCartItems(cart.id);
    } catch (e) {
      _error = e.toString();
      print('Error cargando carrito: $_error');
    } finally {
      _setLoading(false);
    }
  }

  // Cargar los items del carrito
  Future<void> _loadCartItems(int cartId) async {
    try {
      _items = await _cartService.getCartItems(cartId);
    } catch (e) {
      _error = e.toString();
      print('Error cargando items del carrito: $_error');
    }
  }

  // Añadir producto al carrito
  Future<void> addToCart(int productId, int quantity) async {
    if (_cart == null) {
      _error = "No hay un carrito activo";
      notifyListeners();
      return;
    }

    _setLoading(true);
    _error = null;

    try {
      // Usar el nuevo método addToCart
      final newItem = await _cartService.addToCart(
        _cart!.id,
        productId,
        quantity,
      );

      // Actualizar la lista local
      final existingIndex = _items.indexWhere(
        (item) => item.idProducto == productId,
      );
      if (existingIndex >= 0) {
        _items[existingIndex] = newItem;
      } else {
        _items.add(newItem);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error añadiendo al carrito: $_error');
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar la cantidad de un item
  Future<void> updateItemQuantity(int itemId, int newQuantity) async {
    if (newQuantity < 1) return;

    _setLoading(true);
    final tempError = _error; // Guardar el error actual
    _error = null;

    try {
      final updatedItem = await _cartService.updateCartItemQuantity(
        itemId,
        newQuantity,
      );

      // Actualizar la lista de items
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _items[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      print('Error actualizando cantidad: $e');
      // No mostrar el error en la interfaz, solo en consola
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar un item del carrito
  Future<void> removeItem(int itemId) async {
    _setLoading(true);
    final tempError = _error; // Guardar el error actual
    _error = null;

    try {
      await _cartService.removeCartItem(itemId);

      // Eliminar de la lista local
      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      print('Error eliminando item: $e');
      // No mostrar el error en la interfaz, solo en consola
    } finally {
      _setLoading(false);
    }
  }

  // Recargar los items después de una operación
  Future<void> refreshItems() async {
    if (_cart == null) return;

    try {
      _items = await _cartService.getCartItems(_cart!.id);
      _error = null;
      notifyListeners();
    } catch (e) {
      print('Error recargando items del carrito: $e');
      // No mostrar el error en la interfaz, solo en consola
    }
  }

  // Procesar el carrito para pago
  Future<String> checkout(String metodoPago) async {
    if (_cart == null) {
      return 'No hay carrito activo';
    }

    _setLoading(true);
    _error = null;

    try {
      final result = await _cartService.checkoutCart(_cart!.id, metodoPago);
      // Limpiar el carrito local después del checkout
      _items = [];
      _cart = null;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      print('Error en checkout: $_error');
      return 'Error: $_error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearCart(int userId) async {
    try {
      await _cartService.clearCartBackend(userId);
    } catch (e) {
      print("Error limpiando carrito en backend: $e");
    }

    _items = [];
    _cart = null;
    notifyListeners();
  }

  // Método auxiliar para cambiar el estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
