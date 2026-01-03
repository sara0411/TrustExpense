/// Wallet Service
/// 
/// Manages user's Ethereum wallet for blockchain transactions
/// Handles key generation, storage, and transaction signing
/// 
/// COPY TO: lib/data/services/wallet_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'dart:math';
import 'dart:typed_data';

class WalletService {
  static const String _privateKeyKey = 'blockchain_private_key';
  static const String _addressKey = 'blockchain_address';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  EthPrivateKey? _credentials;
  String? _address;
  
  /// Initialize wallet service
  /// 
  /// Loads existing wallet or creates a new one
  Future<void> initialize() async {
    try {
      // Try to load existing wallet
      final privateKeyHex = await _secureStorage.read(key: _privateKeyKey);
      
      if (privateKeyHex != null) {
        // Load existing wallet
        _credentials = EthPrivateKey.fromHex(privateKeyHex);
        _address = await _secureStorage.read(key: _addressKey);
        print('✅ Wallet loaded: $_address');
      } else {
        // Create new wallet
        await _createNewWallet();
        print('✅ New wallet created: $_address');
      }
    } catch (e) {
      print('❌ Failed to initialize wallet: $e');
      rethrow;
    }
  }
  
  /// Create a new wallet
  Future<void> _createNewWallet() async {
    // Generate random private key
    final random = _getSecureRandom();
    final params = ECCurve_secp256k1();
    final keyPair = _generateKeyPair(params, random);
    
    // Get private key bytes
    final privateKey = (keyPair.privateKey as ECPrivateKey).d!;
    final privateKeyBytes = _encodeBigInt(privateKey);
    
    // Create credentials
    _credentials = EthPrivateKey(privateKeyBytes);
    
    // Get address
    final address = await _credentials!.extractAddress();
    _address = address.hex;
    
    // Store securely
    await _secureStorage.write(
      key: _privateKeyKey,
      value: _credentials!.privateKeyInt.toRadixString(16).padLeft(64, '0'),
    );
    await _secureStorage.write(
      key: _addressKey,
      value: _address,
    );
  }
  
  /// Get user's wallet address
  String? get address => _address;
  
  /// Get credentials for signing transactions
  EthPrivateKey? get credentials => _credentials;
  
  /// Check if wallet is initialized
  bool get isInitialized => _credentials != null && _address != null;
  
  /// Get wallet balance (for display purposes)
  Future<EtherAmount> getBalance(Web3Client client) async {
    if (!isInitialized) {
      throw Exception('Wallet not initialized');
    }
    
    final address = EthereumAddress.fromHex(_address!);
    return await client.getBalance(address);
  }
  
  /// Reset wallet (create new one)
  /// 
  /// WARNING: This will delete the current wallet!
  Future<void> resetWallet() async {
    await _secureStorage.delete(key: _privateKeyKey);
    await _secureStorage.delete(key: _addressKey);
    await _createNewWallet();
  }
  
  /// Export private key (for backup)
  /// 
  /// WARNING: Keep this secure! Anyone with the private key can access the wallet
  Future<String?> exportPrivateKey() async {
    return await _secureStorage.read(key: _privateKeyKey);
  }
  
  /// Import wallet from private key
  Future<void> importWallet(String privateKeyHex) async {
    try {
      // Validate and create credentials
      final credentials = EthPrivateKey.fromHex(privateKeyHex);
      final address = await credentials.extractAddress();
      
      // Store
      await _secureStorage.write(key: _privateKeyKey, value: privateKeyHex);
      await _secureStorage.write(key: _addressKey, value: address.hex);
      
      // Update instance
      _credentials = credentials;
      _address = address.hex;
      
      print('✅ Wallet imported: $_address');
    } catch (e) {
      print('❌ Failed to import wallet: $e');
      rethrow;
    }
  }
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  SecureRandom _getSecureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(256));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }
  
  AsymmetricKeyPair<PublicKey, PrivateKey> _generateKeyPair(
    ECCurve_secp256k1 params,
    SecureRandom random,
  ) {
    final keyGen = ECKeyGenerator();
    keyGen.init(ParametersWithRandom(
      ECKeyGeneratorParameters(params),
      random,
    ));
    return keyGen.generateKeyPair();
  }
  
  Uint8List _encodeBigInt(BigInt number) {
    final size = (number.bitLength + 7) >> 3;
    final result = Uint8List(size);
    for (int i = 0; i < size; i++) {
      result[size - i - 1] = (number & BigInt.from(0xff)).toInt();
      number = number >> 8;
    }
    return result;
  }
}
