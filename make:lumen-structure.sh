#!/bin/bash

# Ask for the number of models to create
read -p "Enter the number of models you want to create: " NUMBER_OF_MODELS

for ((i = 1; i <= NUMBER_OF_MODELS; i++)); do
    echo "Creating model $i..."

    # Read input for Module/Class Name
    read -p "Enter Module/Class Name (e.g., Loyalty/Tier): " INPUT

    MODULE_NAME=$(echo "$INPUT" | cut -d'/' -f1)
    CLASS_NAME=$(echo "$INPUT" | cut -d'/' -f2)
    LOWERCASE_MODULE_NAME=$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')
    LOWERCASE_CLASS_NAME=$(echo "$CLASS_NAME" | tr '[:upper:]' '[:lower:]')

    # Create Interface
    INTERFACE_PATH="app/Interfaces/${MODULE_NAME}/${CLASS_NAME}RepositoryInterface.php"
    mkdir -p "$(dirname "$INTERFACE_PATH")"
    cat <<EOT > $INTERFACE_PATH
<?php

namespace App\Interfaces\\${MODULE_NAME};

use Illuminate\Support\Collection;

interface ${CLASS_NAME}RepositoryInterface
{
    public function getAll${CLASS_NAME}s(\$request): Collection|array;
    public function get${CLASS_NAME}ById(\$id): array;
    public function create${CLASS_NAME}(array \$${CLASS_NAME}Details): array;
    public function update${CLASS_NAME}(\$id, array \$newDetails): array;
    public function delete${CLASS_NAME}(\$id): array;
}
EOT

    echo "Created Interface: $INTERFACE_PATH"

    # Create Repository
    REPOSITORY_PATH="app/Repositories/${MODULE_NAME}/${CLASS_NAME}Repository.php"
    mkdir -p "$(dirname "$REPOSITORY_PATH")"
    cat <<EOT > $REPOSITORY_PATH
<?php

namespace App\Repositories\\${MODULE_NAME};

use App\Interfaces\\${MODULE_NAME}\\${CLASS_NAME}RepositoryInterface;
use App\Models\\${MODULE_NAME}\\${CLASS_NAME};
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Collection;

class ${CLASS_NAME}Repository implements ${CLASS_NAME}RepositoryInterface
{
    public function getAll${CLASS_NAME}s(\$request): Collection|array
    {
        return (new ${CLASS_NAME}())->getAll(\$request);
    }

    public function get${CLASS_NAME}ById(\$id): array
    {
        return (new ${CLASS_NAME}())->getById(\$id);
    }

    public function create${CLASS_NAME}(array \$${CLASS_NAME}Details): array
    {
        return (new ${CLASS_NAME}())->createRecord(\$${CLASS_NAME}Details);
    }

    public function update${CLASS_NAME}(\$id, array \$newDetails): array
    {
        return (new ${CLASS_NAME}())->updateRecord(\$id, \$newDetails);
    }

    public function delete${CLASS_NAME}(\$id): array
    {
        return (new ${CLASS_NAME}())->deleteRecord(\$id);
    }
}
EOT

    echo "Created Repository: $REPOSITORY_PATH"

    # Create Model
    MODEL_PATH="app/Models/${MODULE_NAME}/${CLASS_NAME}.php"
    mkdir -p "$(dirname "$MODEL_PATH")"
    cat <<EOT > $MODEL_PATH
<?php

namespace App\Models\\${MODULE_NAME};

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Utils\ModelUtils;
use Illuminate\Database\Eloquent\SoftDeletes;

class ${CLASS_NAME} extends Model
{
    use HasFactory;
    use SoftDeletes;

    protected \$fillable = [];

    public function getAll(\$request): array
    {
        \$response = [];
        try {
            \$currentPage = \$request->input('current_page', 1);
            \$perPage = \$request->input('per_page', 10);

            \$data = self::paginate(\$perPage, ['*'], 'page', \$currentPage);

            if (\$data->isNotEmpty()) {
                \$response['status'] = "success";
                \$response['data'] = \$data;
            } else {
                \$response['status'] = "no_data";
                \$response['data'] = [];
            }
        } catch (\Exception \$e) {
            \$response['status'] = "error";
            \$response['data'] = \$e->getMessage() . "==" . \$e->getLine();
        }

        return \$response;
    }

    public function getById(\$id): array
    {
        \$response = [];
        try {
            \$data = self::find(\$id);

            if (\$data) {
                \$response['status'] = "success";
                \$response['data'] = \$data;
            } else {
                \$response['status'] = "no_data";
                \$response['data'] = [];
            }
        } catch (\Exception \$e) {
            \$response['status'] = "error";
            \$response['data'] = \$e->getMessage() . "==" . \$e->getLine();
        }

        return \$response;
    }

    public function createRecord(array \$options): array
    {
        \$response = [];

        \$validColumns = ModelUtils::getColumnNames(strtolower('${CLASS_NAME}'));
        \$dataToInsert = array_intersect_key(\$options, array_flip(\$validColumns));

        try {
            \$newData = self::create(\$dataToInsert);
            if (isset(\$newData->id)) {
                \$response['status'] = "success";
                \$response['data'] = \$newData;
            } else {
                \$response['status'] = "error";
                \$response['data'] = [];
            }
        } catch (\Exception \$e) {
            \$response['status'] = "error";
            \$response['data'] = \$e->getMessage() . "==" . \$e->getLine();
        }

        return \$response;
    }

    public function updateRecord(\$id, array \$options): array
    {

        \$response = [];

        \$validColumns = ModelUtils::getColumnNames(strtolower('${CLASS_NAME}'));
        \$dataToUpdate = array_intersect_key(\$options, array_flip(\$validColumns));

        try {
            \$affectedRows = self::where('id', \$id)->update(\$dataToUpdate);
            if (\$affectedRows) {
                \$updatedData = self::find(\$id);
                \$response['status'] = "success";
                \$response['data'] = \$updatedData;
            } else {
                \$response['status'] = "error";
                \$response['data'] = [];
            }

        } catch (\Exception \$e) {
            \$response['status'] = "error";
            \$response['data'] = \$e->getMessage() . "==" . \$e->getLine();
        }

        return \$response;
    }

    public function deleteRecord(\$id): array
{
    \$response = [];

    try {
        // Find the record by ID
        \$oldTier = self::find(\$id);

        if (\$oldTier) {
            // Soft delete the record by updating the 'deleted_at' column
            \$result = \$oldTier->update(['deleted_at' => now()]);

            if (\$result) {
                \$response['status'] = "success";
                \$response['data'] = \$result;
            } else {
                \$response['status'] = "error";
                \$response['data'] = [];
            }
        } else {
            \$response['status'] = "no_data";
            \$response['data'] = [];
        }
    } catch (\Exception \$e) {
        \$response['status'] = "error";
        \$response['data'] = \$e->getMessage() . "==" . \$e->getLine();
    }

    return \$response;
}

}
EOT

    echo "Created Model: $MODEL_PATH"

    # Create Controller in Dynamic Module Directory
    CONTROLLER_PATH="app/Http/Controllers/${MODULE_NAME}/${CLASS_NAME}Controller.php"
    mkdir -p "$(dirname "$CONTROLLER_PATH")"
    cat <<EOT > $CONTROLLER_PATH
<?php

namespace App\Http\Controllers\\${MODULE_NAME};

use App\Interfaces\\${MODULE_NAME}\\${CLASS_NAME}RepositoryInterface;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

class ${CLASS_NAME}Controller extends Controller
{
    protected \$${CLASS_NAME}Repository;

    public function __construct(${CLASS_NAME}RepositoryInterface \$${CLASS_NAME}Repository)
    {
        \$this->${CLASS_NAME}Repository = \$${CLASS_NAME}Repository;
    }

    public function index(Request \$request): JsonResponse
    {
        \$response = [];
        \$result = \$this->${CLASS_NAME}Repository->getAll${CLASS_NAME}s(\$request);

        if (\$result['status'] == "success") {
            \$response["code"] = 200;
            \$response["status"] = "success";
            \$response["message"] = "${CLASS_NAME} list";
        } elseif (\$result['status'] == "no_data") {
            \$response["code"] = 200;
            \$response["status"] = "success";
            \$response["message"] = "No ${CLASS_NAME}s found";
        } else {
            \$response["code"] = 400;
            \$response["status"] = "error";
            \$response["message"] = "Something went wrong";
        }

        \$response["content"] = \$result['data'];
        return response()->json(\$response);
    }

    public function show(\$id): JsonResponse
    {
        \$response = [];
        \$result = \$this->${CLASS_NAME}Repository->get${CLASS_NAME}ById(\$id);

        if (\$result['status'] == "success") {
            \$response["code"] = 200;
            \$response["status"] = "success";
            \$response["message"] = "${CLASS_NAME} details";
        } elseif (\$result['status'] == "no_data") {
            \$response["code"] = 200;
            \$response["status"] = "success";
            \$response["message"] = "No ${CLASS_NAME} found";
        } else {
            \$response["code"] = 400;
            \$response["status"] = "error";
            \$response["message"] = "Something went wrong";
        }

        \$response["content"] = \$result['data'];
        return response()->json(\$response);
    }

    public function store(Request \$request): JsonResponse
    {
        \$response = [];
        \$result = \$this->${CLASS_NAME}Repository->create${CLASS_NAME}(\$request->all());

        if (\$result['status'] == "success") {
            \$response["code"] = 200;
            \$response["status"] = "success";
            \$response["message"] = "${CLASS_NAME} created successfully";
        } else {
            \$response["code"] = 400;
            \$response["status"] = "error";
            \$response["message"] = "Something went wrong";
        }

        \$response["content"] = \$result['data'];
        return response()->json(\$response);
    }

    public function update(Request \$request, \$id): JsonResponse
    {
        \$response = [];
        \$result = \$this->${CLASS_NAME}Repository->update${CLASS_NAME}(\$id, \$request->all());

        if (\$result['status'] == "success") {
            \$response["code"] = 200;
            \$response["status"] = "success";
            \$response["message"] = "${CLASS_NAME} updated successfully";
        } else {
            \$response["code"] = 400;
            \$response["status"] = "error";
            \$response["message"] = "Something went wrong";
        }

        \$response["content"] = \$result['data'];
        return response()->json(\$response);
    }

    public function destroy(\$id): JsonResponse
    {
        \$response = [];
        \$result = \$this->${CLASS_NAME}Repository->delete${CLASS_NAME}(\$id);

        if (\$result['status'] == "success") {
            \$response["code"] = 200;
            \$response["status"] = "success";
            \$response["message"] = "${CLASS_NAME} deleted successfully";
        } else {
            \$response["code"] = 400;
            \$response["status"] = "error";
            \$response["message"] = "Something went wrong";
        }

        \$response["content"] = \$result['data'];
        return response()->json(\$response);
    }
}
EOT

    echo "Created Controller: $CONTROLLER_PATH"
done


# Create the ModelUtils class
UTILS_PATH="app/Utils/ModelUtils.php"
mkdir -p "$(dirname "$UTILS_PATH")"
cat <<EOT > $UTILS_PATH
<?php

namespace App\Utils;

use Illuminate\Support\Facades\DB;

class ModelUtils
{
    public static function getColumnNames(string \$tableName): array
    {
        return DB::getSchemaBuilder()->getColumnListing(\$tableName);
    }

    public static function getNonNullAttributes(array \$attributes): array
    {
        return array_filter(\$attributes, function (\$value) {
            return !is_null(\$value);
        });
    }

    public static function formatDates(array \$attributes, array \$dateFields = ['start_date', 'end_date', 'created_at', 'updated_at', 'deleted_at']): array
    {
        foreach (\$dateFields as \$dateField) {
            if (isset(\$attributes[\$dateField])) {
                \$attributes[\$dateField] = date('Y-m-d', strtotime(\$attributes[\$dateField]));
            }
        }
        return \$attributes;
    }
}
EOT

echo "Created ModelUtils: $UTILS_PATH"
