import '../auth/session_controller.dart';
import '../data/inventory_repository.dart';

// Installed once by the production or demo entry point. Repositories remain
// injectable and never create their own Supabase client.
late SessionController sessionController;
late InventoryRepository inventoryRepository;
bool isDemo = false;
