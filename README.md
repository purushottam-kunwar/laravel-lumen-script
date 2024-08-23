---

# Model and Repository Generator Script

This script helps in automating the creation of Laravel Models, Repositories, Interfaces, and Controllers. It prompts the user for input and generates the necessary files for each model.

## Script Functionality

The script performs the following actions:

1. **Prompts for the Number of Models**: Asks the user how many models they wish to create.
2. **Prompts for Module/Class Names**: For each model, it prompts the user to input a Module/Class name in the format `Module/Class` (e.g., `Loyalty/Tier`).
3. **Generates Files**: For each model, the script generates the following files:
   - **Interface**: Located in `app/Interfaces/[Module]/[Class]RepositoryInterface.php`
   - **Repository**: Located in `app/Repositories/[Module]/[Class]Repository.php`
   - **Model**: Located in `app/Models/[Module]/[Class].php`
   - **Controller**: Located in `app/Http/Controllers/[Module]/[Class]Controller.php`

4. **Creates a Utility Class**: Generates a utility class `ModelUtils` in `app/Utils/ModelUtils.php` with methods for retrieving column names, filtering non-null attributes, and formatting date fields.

## Generated File Structure

- `app/Interfaces/[Module]/[Class]RepositoryInterface.php`: Interface for the repository with basic CRUD operations.
- `app/Repositories/[Module]/[Class]Repository.php`: Repository implementing the interface and interacting with the model.
- `app/Models/[Module]/[Class].php`: Eloquent Model class with methods for CRUD operations.
- `app/Http/Controllers/[Module]/[Class]Controller.php`: Controller class handling HTTP requests and invoking repository methods.
- `app/Utils/ModelUtils.php`: Utility class with common model-related functions.

## Usage

1. **Run the Script**: Execute the script in your terminal.
   ```bash
   ./generate_models.sh
   ```

2. **Enter the Number of Models**: When prompted, input the number of models you want to create.

3. **Provide Module/Class Names**: For each model, input the Module and Class name in the format `Module/Class` (e.g., `Loyalty/Tier`).

4. **Script Output**: The script will generate the necessary files and provide the paths to each created file.

## Example

If you input:
- Number of models: `2`
- Module/Class Name for first model: `Loyalty/Tier`
- Module/Class Name for second model: `Product/Category`

The script will generate:
- Interfaces, Repositories, Models, and Controllers for both `Tier` and `Category`.
- A utility class `ModelUtils` that can be used across models.

---
