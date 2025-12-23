-- TrustExpense Database Schema for Supabase (PostgreSQL)
-- Run this SQL in your Supabase SQL Editor to create the required tables

-- ============================================================================
-- RECEIPTS TABLE
-- ============================================================================
-- Stores individual receipt/expense records
-- Each receipt contains OCR text, AI-predicted category, and metadata

CREATE TABLE IF NOT EXISTS receipts (
  -- Primary key (auto-generated UUID)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign key to Supabase auth.users table
  -- Links receipt to the user who created it
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Receipt financial data
  amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),  -- Total amount spent
  date TIMESTAMP WITH TIME ZONE NOT NULL,              -- Transaction date
  merchant TEXT NOT NULL,                              -- Store/vendor name
  
  -- AI Classification results
  category TEXT NOT NULL,                              -- Expense category (Food, Transport, etc.)
  category_confidence DECIMAL(3, 2) DEFAULT 0.0,       -- AI confidence score (0.00-1.00)
  manual_override BOOLEAN DEFAULT FALSE,               -- True if user manually changed category
  
  -- Receipt data
  image_url TEXT,                                      -- Supabase Storage URL for receipt image
  ocr_text TEXT,                                       -- Full text extracted via OCR
  
  -- Timestamps (auto-managed by Supabase)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on user_id for faster queries
CREATE INDEX IF NOT EXISTS idx_receipts_user_id ON receipts(user_id);

-- Create index on date for faster date-range queries
CREATE INDEX IF NOT EXISTS idx_receipts_date ON receipts(date);

-- Create index on category for faster category filtering
CREATE INDEX IF NOT EXISTS idx_receipts_category ON receipts(category);

-- Enable Row Level Security (RLS)
ALTER TABLE receipts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own receipts
CREATE POLICY "Users can view own receipts"
  ON receipts FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own receipts
CREATE POLICY "Users can insert own receipts"
  ON receipts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own receipts
CREATE POLICY "Users can update own receipts"
  ON receipts FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can delete their own receipts
CREATE POLICY "Users can delete own receipts"
  ON receipts FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- MONTHLY SUMMARIES TABLE
-- ============================================================================
-- Stores aggregated monthly spending data for faster summary queries
-- This is a materialized view that gets updated when receipts change

CREATE TABLE IF NOT EXISTS monthly_summaries (
  -- Primary key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign key to user
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Month identifier (stored as first day of month, e.g., '2024-01-01')
  month DATE NOT NULL,
  
  -- Aggregated data
  total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,      -- Total spending for the month
  receipt_count INTEGER NOT NULL DEFAULT 0,            -- Number of receipts
  category_breakdown JSONB,                            -- JSON object with category totals
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure one summary per user per month
  UNIQUE(user_id, month)
);

-- Create index on user_id and month for faster queries
CREATE INDEX IF NOT EXISTS idx_summaries_user_month ON monthly_summaries(user_id, month);

-- Enable Row Level Security
ALTER TABLE monthly_summaries ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own summaries
CREATE POLICY "Users can view own summaries"
  ON monthly_summaries FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own summaries
CREATE POLICY "Users can insert own summaries"
  ON monthly_summaries FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own summaries
CREATE POLICY "Users can update own summaries"
  ON monthly_summaries FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================================================
-- STORAGE BUCKET FOR RECEIPT IMAGES
-- ============================================================================
-- Run this in the Supabase Storage section (not SQL Editor)
-- Or use the Supabase Dashboard to create a bucket named 'receipts'

-- Bucket name: receipts
-- Public: false (only authenticated users can access)
-- File size limit: 5MB
-- Allowed MIME types: image/jpeg, image/png, image/jpg

-- Storage Policy: Users can upload their own receipt images
-- CREATE POLICY "Users can upload own receipts"
--   ON storage.objects FOR INSERT
--   WITH CHECK (
--     bucket_id = 'receipts' AND
--     auth.uid()::text = (storage.foldername(name))[1]
--   );

-- Storage Policy: Users can view their own receipt images
-- CREATE POLICY "Users can view own receipts"
--   ON storage.objects FOR SELECT
--   USING (
--     bucket_id = 'receipts' AND
--     auth.uid()::text = (storage.foldername(name))[1]
--   );

-- ============================================================================
-- HELPER FUNCTIONS (Optional)
-- ============================================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at on receipts table
CREATE TRIGGER update_receipts_updated_at
  BEFORE UPDATE ON receipts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger to auto-update updated_at on monthly_summaries table
CREATE TRIGGER update_summaries_updated_at
  BEFORE UPDATE ON monthly_summaries
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================

-- Insert sample categories (you can customize these)
-- Note: Replace 'YOUR_USER_ID' with an actual user ID from auth.users

-- INSERT INTO receipts (user_id, amount, date, merchant, category, category_confidence, ocr_text)
-- VALUES
--   ('YOUR_USER_ID', 45.99, '2024-01-15', 'Starbucks', 'Food & Dining', 0.92, 'STARBUCKS\nCoffee: $4.50\nSandwich: $8.99\nTotal: $45.99'),
--   ('YOUR_USER_ID', 65.00, '2024-01-16', 'Shell Gas Station', 'Transportation', 0.88, 'SHELL\nGasoline\nTotal: $65.00'),
--   ('YOUR_USER_ID', 129.99, '2024-01-17', 'Amazon', 'Shopping', 0.95, 'Amazon.com\nElectronics\nTotal: $129.99');

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check if tables were created successfully
-- SELECT table_name FROM information_schema.tables 
-- WHERE table_schema = 'public' AND table_name IN ('receipts', 'monthly_summaries');

-- Count receipts
-- SELECT COUNT(*) FROM receipts;

-- View recent receipts
-- SELECT id, merchant, amount, category, date FROM receipts ORDER BY date DESC LIMIT 10;
