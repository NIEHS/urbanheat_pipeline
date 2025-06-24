output_dir="./output/*"
artefacts=$(cat list_artefacts.txt)

for folder in $output_dir; do
    folder_name=$(basename "$folder")
    # Check if the folder is in the artefacts list
    if echo "$artefacts" | grep -q "^$folder_name$"; then
        echo "Skipping: $folder_name is listed in list_artefacts.txt"
        tar -czf "./shared_dataset_harvard/artefacts_not_published/${folder_name}.tar.gz" -C "${output_dir%/*}" "$folder_name"
        continue
    fi
    echo "Keeping: $folder_name"
    tar -czf "./shared_dataset_harvard/${folder_name}.tar.gz" -C "${output_dir%/*}" "$folder_name"
done

# Group folders by the last 6 digits and compress them
declare -A grouped_folders

for folder in $output_dir; do
    folder_name=$(basename "$folder")
    # Check if the folder is in the artefacts list
    if echo "$artefacts" | grep -q "^$folder_name$"; then
        echo "Skipping: $folder_name is listed in list_artefacts.txt"
        continue
    fi
    echo "Keeping: $folder_name"
    key=${folder_name: -6} # Extract the last 6 characters
    grouped_folders["$key"]+="$folder_name "
done

for key in "${!grouped_folders[@]}"; do
    tar -czf "./shared_dataset_cebs/top_us_cities_${key}.tar.gz" -C "${output_dir%/*}" ${grouped_folders[$key]}
done


output_dir="./output/*"
exclude_list=$(ls ./shared_dataset_harvard/push_2025-06-09/ | sed 's/\.tar\.gz$//')
destination_dir="./shared_dataset_harvard/push_2025-06-24/"

# Ensure the destination directory exists
mkdir -p "$destination_dir"

for folder in $output_dir; do
    folder_name=$(basename "$folder")
    
    # Check if the folder is in the exclude list
    if echo "$exclude_list" | grep -q "^$folder_name$"; then
        echo "Skipping: $folder_name is listed in /shared_dataset_harvard/push_2025-06-09/"
        continue
    fi
    
    # Compress the folder into the destination directory
    echo "Compressing: $folder_name"
    tar -czf "${destination_dir}/${folder_name}.tar.gz" -C "${output_dir%/*}" "$folder_name"
done