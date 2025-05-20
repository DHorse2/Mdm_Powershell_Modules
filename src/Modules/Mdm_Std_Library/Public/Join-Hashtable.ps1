
# Merge-Parameters
function Join-Hashtable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$params1,
        [Parameter(Mandatory=$true)]
        [hashtable]$params2
    )
    begin {
        [hashtable]$newParams = @{}
    }
    process {
        $params1.GetEnumerator() | ForEach-Object {
            $newParams[$_.Key] = $_.Value
        }
        $params2.GetEnumerator() | ForEach-Object {
            $newParams[$_.Key] = $_.Value
        }
    }
    end {
        return $newParams
    }
}
