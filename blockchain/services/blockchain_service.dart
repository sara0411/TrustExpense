/// Blockchain Service
/// 
/// Handles all interactions with the Polygon Mumbai blockchain.
/// Manages Web3 connection, transaction submission, and certificate verification.
/// 
/// IMPORTANT: Copy this file to lib/data/services/blockchain_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

// Import these from your project
// import '../../core/constants/blockchain_constants.dart';

class BlockchainService {
  late Web3Client _client;
  late DeployedContract _contract;
  late ContractFunction _certifyFunction;
  late ContractFunction _verifyFunction;
  
  bool _initialized = false;
  
  /// Initialize the blockchain service
  /// 
  /// Connects to Polygon Mumbai RPC and loads the smart contract ABI
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Create Web3 client with Mumbai RPC
      _client = Web3Client(
        'https://rpc-mumbai.maticvigil.com/', // BlockchainConstants.rpcUrl
        Client(),
      );
      
      // Load contract ABI from assets
      final abiJson = await rootBundle.loadString(
        'assets/blockchain/ReceiptCertifier.json',
      );
      final abi = jsonDecode(abiJson) as List<dynamic>;
      
      // Create contract instance
      final contractAddress = EthereumAddress.fromHex(
        '0xYOUR_CONTRACT_ADDRESS_HERE', // BlockchainConstants.contractAddress
      );
      
      _contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(abi), 'ReceiptCertifier'),
        contractAddress,
      );
      
      // Get contract functions
      _certifyFunction = _contract.function('certifyReceipt');
      _verifyFunction = _contract.function('verifyCertificate');
      
      _initialized = true;
      print('✅ Blockchain service initialized');
    } catch (e) {
      print('❌ Failed to initialize blockchain service: $e');
      rethrow;
    }
  }
  
  /// Certify a receipt on the blockchain
  /// 
  /// @param receiptHash SHA-256 hash of the receipt data (as hex string)
  /// @param credentials User's wallet credentials
  /// @return Transaction hash
  Future<String> certifyReceipt(
    String receiptHash,
    Credentials credentials,
  ) async {
    if (!_initialized) await initialize();
    
    try {
      // Convert hex string to bytes32
      final hashBytes = hexToBytes(receiptHash);
      
      // Call certifyReceipt function
      final transaction = Transaction.callContract(
        contract: _contract,
        function: _certifyFunction,
        parameters: [hashBytes],
      );
      
      // Send transaction
      final txHash = await _client.sendTransaction(
        credentials,
        transaction,
        chainId: 80001, // Mumbai chain ID
      );
      
      print('📤 Certificate transaction sent: $txHash');
      return txHash;
    } catch (e) {
      print('❌ Failed to certify receipt: $e');
      rethrow;
    }
  }
  
  /// Verify a certificate on the blockchain
  /// 
  /// @param certificateId The certificate ID to verify
  /// @return Verification result with certificate data
  Future<CertificateVerificationResult> verifyCertificate(
    String certificateId,
  ) async {
    if (!_initialized) await initialize();
    
    try {
      // Convert certificate ID to bytes32
      final certIdBytes = hexToBytes(certificateId);
      
      // Call verifyCertificate function (read-only, no gas)
      final result = await _client.call(
        contract: _contract,
        function: _verifyFunction,
        params: [certIdBytes],
      );
      
      // Parse result
      final isValid = result[0] as bool;
      final receiptHash = bytesToHex(result[1] as List<int>, include0x: true);
      final certifier = (result[2] as EthereumAddress).hex;
      final timestamp = (result[3] as BigInt).toInt();
      
      return CertificateVerificationResult(
        isValid: isValid,
        receiptHash: receiptHash,
        certifierAddress: certifier,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      );
    } catch (e) {
      print('❌ Failed to verify certificate: $e');
      rethrow;
    }
  }
  
  /// Wait for transaction confirmation
  /// 
  /// @param txHash Transaction hash to monitor
  /// @param confirmations Number of confirmations to wait for
  /// @return Transaction receipt
  Future<TransactionReceipt?> waitForConfirmation(
    String txHash, {
    int confirmations = 2,
    Duration timeout = const Duration(seconds: 120),
  }) async {
    final startTime = DateTime.now();
    
    while (DateTime.now().difference(startTime) < timeout) {
      try {
        final receipt = await _client.getTransactionReceipt(txHash);
        
        if (receipt != null) {
          // Check if transaction was successful
          if (receipt.status == true) {
            print('✅ Transaction confirmed: $txHash');
            return receipt;
          } else {
            print('❌ Transaction failed: $txHash');
            return receipt;
          }
        }
        
        // Wait before checking again
        await Future.delayed(const Duration(seconds: 3));
      } catch (e) {
        print('⏳ Waiting for confirmation: $e');
        await Future.delayed(const Duration(seconds: 3));
      }
    }
    
    print('⏱️ Transaction confirmation timeout: $txHash');
    return null;
  }
  
  /// Get current block number
  Future<int> getBlockNumber() async {
    if (!_initialized) await initialize();
    final blockNum = await _client.getBlockNumber();
    return blockNum;
  }
  
  /// Dispose resources
  void dispose() {
    _client.dispose();
    _initialized = false;
  }
}

/// Result of certificate verification
class CertificateVerificationResult {
  final bool isValid;
  final String receiptHash;
  final String certifierAddress;
  final DateTime timestamp;
  
  CertificateVerificationResult({
    required this.isValid,
    required this.receiptHash,
    required this.certifierAddress,
    required this.timestamp,
  });
}
