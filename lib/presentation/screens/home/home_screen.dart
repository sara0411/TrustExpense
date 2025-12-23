// ═══════════════════════════════════════════════════════════════════════════
// FLUTTER IMPORTS
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart'; // Core Flutter UI framework - provides widgets, themes, navigation
import '../receipt/receipt_capture_screen.dart'; // Import the receipt capture screen for scanning functionality

/// ═══════════════════════════════════════════════════════════════════════════
/// HOME SCREEN - Main Landing Page
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// This is the FIRST screen users see when they open the app. It serves as the
/// main hub for all app functionality.
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// SCREEN PURPOSE
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// The home screen provides:
/// 1. Quick access to scan receipts (primary action)
/// 2. Navigation to view receipt history
/// 3. Navigation to view expense summary/analytics
/// 4. Clean, simple UI that's easy to understand
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// DESIGN PHILOSOPHY
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// - Minimalist: Only essential elements, no clutter
/// - Action-focused: Primary button is prominent and clear
/// - Accessible: Large touch targets, clear labels
/// - Consistent: Uses Material Design 3 principles
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// WIDGET TYPE: StatelessWidget
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Why StatelessWidget?
/// - This screen has no internal state that changes
/// - All data comes from parent (navigation callback)
/// - More efficient than StatefulWidget
/// - Rebuilds only when parent rebuilds
/// 
/// ═══════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatelessWidget {
  // ═══════════════════════════════════════════════════════════════════════════
  // PROPERTIES
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Navigation callback function
  /// 
  /// This function is provided by the parent widget (MainScreen) and allows
  /// this screen to request navigation to other tabs.
  /// 
  /// Parameters:
  ///   index: The tab index to navigate to
  ///   - 0 = Home (this screen)
  ///   - 1 = History
  ///   - 2 = Summary
  /// 
  /// Why use a callback instead of Navigator.push?
  /// - This screen is part of a bottom navigation bar setup
  /// - We want to switch tabs, not push new routes
  /// - Parent controls the navigation state
  final Function(int) onNavigate;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Creates a HomeScreen widget
  /// 
  /// Parameters:
  ///   key: Optional widget key for Flutter's widget tree (used for optimization)
  ///   onNavigate: Required callback for tab navigation
  /// 
  /// The 'const' keyword makes this constructor a compile-time constant,
  /// which improves performance by allowing Flutter to reuse widget instances
  const HomeScreen({
    super.key, // Pass key to parent StatelessWidget
    required this.onNavigate, // onNavigate is required - app won't compile without it
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD METHOD - Constructs the UI
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Builds the widget tree for this screen
  /// 
  /// This method is called:
  /// - When the screen is first displayed
  /// - When the parent widget rebuilds
  /// - When the app theme changes
  /// - When device orientation changes
  /// 
  /// Parameters:
  ///   context: BuildContext provides access to:
  ///   - Theme data
  ///   - Media queries (screen size, orientation)
  ///   - Navigation
  ///   - Inherited widgets
  /// 
  /// Returns:
  ///   Widget tree representing the entire screen
  @override
  Widget build(BuildContext context) {
    // ─────────────────────────────────────────────────────────────────────────
    // SCAFFOLD - Material Design screen structure
    // ─────────────────────────────────────────────────────────────────────────
    // Scaffold provides the basic visual structure:
    // - AppBar at the top
    // - Body in the middle
    // - Optional: BottomNavigationBar, FloatingActionButton, Drawer
    return Scaffold(
      // ───────────────────────────────────────────────────────────────────────
      // BACKGROUND COLOR
      // ───────────────────────────────────────────────────────────────────────
      // Pure white background for clean, modern look
      // Alternative: Could use Theme.of(context).scaffoldBackgroundColor
      backgroundColor: Colors.white,
      
      // ───────────────────────────────────────────────────────────────────────
      // APP BAR - Top navigation bar
      // ───────────────────────────────────────────────────────────────────────
      // AppBar is a Material Design component that provides:
      // - App title/branding
      // - Navigation controls (back button, menu)
      // - Actions (search, settings, etc.)
      appBar: AppBar(
        // App title - displayed in the center or left (platform-dependent)
        title: const Text('TrustExpense'),
        
        // Background color - green to match app branding
        // Using Colors.green (Material Design color palette)
        backgroundColor: Colors.green,
        
        // Foreground color - affects title text and icons
        // White text on green background for good contrast
        foregroundColor: Colors.white,
      ),
      
      // ───────────────────────────────────────────────────────────────────────
      // BODY - Main content area
      // ───────────────────────────────────────────────────────────────────────
      // Center widget centers its child both horizontally and vertically
      // This creates a centered layout regardless of screen size
      body: Center(
        // Padding adds space around the content
        // EdgeInsets.all(20.0) = 20 pixels on all sides
        // This prevents content from touching screen edges
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          
          // ─────────────────────────────────────────────────────────────────
          // COLUMN - Vertical layout
          // ─────────────────────────────────────────────────────────────────
          // Column arranges children vertically (top to bottom)
          // Similar to a vertical stack or flexbox column
          child: Column(
            // MainAxisAlignment.center - center children vertically
            // This pushes content to the middle of the screen
            mainAxisAlignment: MainAxisAlignment.center,
            
            // Children - list of widgets to display vertically
            children: [
              // ───────────────────────────────────────────────────────────────
              // APP ICON - Visual branding
              // ───────────────────────────────────────────────────────────────
              // Icon widget displays Material Design icons
              // Icons.receipt_long - a receipt icon from Material Icons
              const Icon(
                Icons.receipt_long, // Icon identifier
                size: 80, // Icon size in logical pixels
                color: Colors.green, // Icon color (matches app theme)
              ),
              
              // ───────────────────────────────────────────────────────────────
              // SPACING - Vertical gap
              // ───────────────────────────────────────────────────────────────
              // SizedBox creates empty space
              // height: 40 = 40 pixels of vertical space
              // This separates the icon from the button
              const SizedBox(height: 40),
              
              // ───────────────────────────────────────────────────────────────
              // PRIMARY ACTION BUTTON - Scan Receipt
              // ───────────────────────────────────────────────────────────────
              // ElevatedButton.icon creates a raised button with icon + text
              // This is the MAIN action users will take
              ElevatedButton.icon(
                // ─────────────────────────────────────────────────────────────
                // ON PRESSED - Button click handler
                // ─────────────────────────────────────────────────────────────
                // This function runs when the button is tapped
                onPressed: () {
                  // Show a modal bottom sheet (slides up from bottom)
                  // This is a common mobile UI pattern for quick actions
                  showModalBottomSheet(
                    context: context, // Required for navigation
                    
                    // isScrollControlled: true allows the sheet to take full height
                    // Useful for sheets with lots of content
                    isScrollControlled: true,
                    
                    // Builder function creates the sheet content
                    // The underscore (_) means we don't use the context parameter
                    builder: (_) => const ReceiptCaptureScreen(),
                  );
                },
                
                // ─────────────────────────────────────────────────────────────
                // BUTTON ICON
                // ─────────────────────────────────────────────────────────────
                // Camera icon indicates photo capture functionality
                icon: const Icon(
                  Icons.camera_alt, // Camera icon
                  size: 28, // Slightly larger than default for visibility
                ),
                
                // ─────────────────────────────────────────────────────────────
                // BUTTON LABEL
                // ─────────────────────────────────────────────────────────────
                // Text widget displays the button label
                label: const Text(
                  'Scan Receipt', // Clear, action-oriented label
                  style: TextStyle(fontSize: 20), // Larger text for emphasis
                ),
                
                // ─────────────────────────────────────────────────────────────
                // BUTTON STYLING
                // ─────────────────────────────────────────────────────────────
                // ElevatedButton.styleFrom provides button customization
                style: ElevatedButton.styleFrom(
                  // Background color - green to match app theme
                  backgroundColor: Colors.green,
                  
                  // Foreground color - white text and icon
                  foregroundColor: Colors.white,
                  
                  // Padding - space inside the button
                  // horizontal: 40 = left/right padding
                  // vertical: 20 = top/bottom padding
                  // This makes the button larger and easier to tap
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  
                  // Shape - rounded corners for modern look
                  // BorderRadius.circular(12) = 12-pixel radius corners
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              // ───────────────────────────────────────────────────────────────
              // SPACING
              // ───────────────────────────────────────────────────────────────
              const SizedBox(height: 20),
              
              // ───────────────────────────────────────────────────────────────
              // SECONDARY ACTION - View History
              // ───────────────────────────────────────────────────────────────
              // TextButton is a flat button (no elevation)
              // Used for secondary actions that are less important
              TextButton(
                // Navigate to History tab (index 1)
                // Uses the callback provided by parent
                onPressed: () => onNavigate(1),
                
                // Button label
                child: const Text(
                  'View History',
                  style: TextStyle(fontSize: 16), // Smaller than primary button
                ),
              ),
              
              // ───────────────────────────────────────────────────────────────
              // SPACING
              // ───────────────────────────────────────────────────────────────
              const SizedBox(height: 10),
              
              // ───────────────────────────────────────────────────────────────
              // TERTIARY ACTION - View Summary
              // ───────────────────────────────────────────────────────────────
              // Another secondary action button
              TextButton(
                // Navigate to Summary tab (index 2)
                onPressed: () => onNavigate(2),
                
                // Button label
                child: const Text(
                  'View Summary',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// WIDGET TREE STRUCTURE
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// HomeScreen
/// └── Scaffold
///     ├── AppBar
///     │   └── Text("TrustExpense")
///     └── Body: Center
///         └── Padding
///             └── Column
///                 ├── Icon (receipt icon)
///                 ├── SizedBox (spacing)
///                 ├── ElevatedButton.icon (Scan Receipt)
///                 │   ├── Icon (camera)
///                 │   └── Text ("Scan Receipt")
///                 ├── SizedBox (spacing)
///                 ├── TextButton (View History)
///                 │   └── Text ("View History")
///                 ├── SizedBox (spacing)
///                 └── TextButton (View Summary)
///                     └── Text ("View Summary")
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// USER INTERACTION FLOW
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// 1. User opens app → HomeScreen displays
/// 2. User taps "Scan Receipt" → Bottom sheet opens with camera/gallery options
/// 3. User taps "View History" → Navigates to History tab (shows all receipts)
/// 4. User taps "View Summary" → Navigates to Summary tab (shows analytics)
/// 
/// ═══════════════════════════════════════════════════════════════════════════
/// FLUTTER CONCEPTS DEMONSTRATED
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// 1. StatelessWidget - Immutable widget with no internal state
/// 2. Scaffold - Material Design screen structure
/// 3. AppBar - Top navigation bar
/// 4. Column - Vertical layout
/// 5. Center - Centering widget
/// 6. Padding - Adding space around widgets
/// 7. Icon - Displaying Material icons
/// 8. ElevatedButton - Raised button with elevation
/// 9. TextButton - Flat button for secondary actions
/// 10. SizedBox - Creating spacing
/// 11. showModalBottomSheet - Displaying bottom sheets
/// 12. Callbacks - Passing functions as parameters
/// 
/// ═══════════════════════════════════════════════════════════════════════════
