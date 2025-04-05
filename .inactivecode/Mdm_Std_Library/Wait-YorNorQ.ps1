# Wait-YorNorQ
function Wait-YorNorQ {
    param([string] $message)
    if ($Global:pauseDo) {
        # if ($null -eq $message -or $message -eq "") {
        #     $null
        #     Write-Output "The variable is either null or empty."
        # } else {
        #     Write-Output "The variable is not null and not empty."
        # }
        if ([string]::IsNullOrEmpty($message)) {
            $message = 'Do you want to continue? Press Y for Yes or N to exit'
        }
        # if ($message.Length = = 0) {
        #     $message = 'Do you want to continue? Press Y for Yes or N to exit'
        # }
        $continue = 1
        Do {
            # $response = Read-Host -Prompt $message
            $response = Read-Host $message
            Switch ($response) {
                Y { 
                    $continue = 0
                    Write-Host 'The script is continuing'
                    return $response
                    break
                }
                N { 
                    $continue = 0
                    return $response
                    break }
                Q { exit }
            }
        } while ($continue -ne 0)
        # Write-Host 'The script executes yet another instruction'
    } else { return $null }
    return $null
}
#
#############################
#
