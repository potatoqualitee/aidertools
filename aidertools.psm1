function Import-ModuleFile {
    [CmdletBinding()]
    Param (
        [string]
        $Path
    )
    if ($doDotSource) { . $Path }
    else { $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($Path))), $null, $null) }
}

foreach ($function in (Get-ChildItem "$ModuleRoot\private\" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

# Import all public functions
foreach ($function in (Get-ChildItem "$ModuleRoot\public" -Filter "*.ps1" -Recurse -ErrorAction Ignore)) {
    . Import-ModuleFile -Path $function.FullName
}

# Helper function to join hashtable
function Join-Hashtable {
    $output = @{}
    foreach ($item in $input) {
        foreach ($key in $item.Keys) {
            $output[$key] = $item[$key]
        }
    }
    return $output
}