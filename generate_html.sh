#!/bin/bash
golinks_html=build/index.html

# Create the build directory if it doesn't exist
mkdir -p build

# Create the HTML file using the JSON data
cat <<EOL >$golinks_html
<!DOCTYPE html>
<html>
<head>
    <title>lucetre GitHub Go Links</title>
    <style>
      table {
        border-collapse: collapse;
        width: 100%;
      }
      th,
      td {
        border: 1px solid #ddd;
        padding: 8px;
        text-align: left;
      }
      th {
        background-color: #f2f2f2;
      }
    </style>
</head>
<body>
    <h1>Redirect Server Subpaths</h1>
    <table>
        <tr>
            <th>Subpath</th>
            <th>Redirect Link</th>
        </tr>
EOL

# Loop through the JSON data and generate the table rows
jq -r '. | to_entries[] | "<tr><td><a href=\"/go" + .key + "\">/go" + .key + "</a></td><td><a href=\"" + .value + "\">" + .value + "</a></td></tr>"' golinks.json >>$golinks_html

# Complete the HTML file
echo "</table></body></html>" >>$golinks_html
echo "Generated $golinks_html successfully!"

# Read the golinks.json file and extract the subpath and redirect-link key-value pairs
subpaths=($(jq -r 'keys[]' golinks.json))
redirect_links=($(jq -r '.[]' golinks.json))

# Loop through the subpaths and create index.html for each one
for ((i = 0; i < ${#subpaths[@]}; i++)); do
    subpath=${subpaths[$i]}
    redirect_link=${redirect_links[$i]}

    # Create the content for the index.html file
    content="<!DOCTYPE html>
<meta charset=utf-8>
<title>Redirecting to $redirect_link</title>
<meta http-equiv=refresh content=\"0; URL=$redirect_link\">
<link rel=canonical href=\"$redirect_link\">
"

    # Create the directory for the subpath if it doesn't exist
    mkdir -p "build$subpath"

    # Write the content to the index.html file
    echo "$content" >"build$subpath/index.html"
done

echo "Created subdirectories with index.html files successfully!"
