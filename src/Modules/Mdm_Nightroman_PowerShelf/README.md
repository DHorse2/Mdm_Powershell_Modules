# PowerShelf

PowerShell script tools for various tasks, mostly standalone.

## Scripts

* *Add-Debugger.ps1* - Adds a script debugger to PowerShell.
* *Add-Path.ps1* - Adds a directory to an environment path variable.
* *Assert-SameFile.ps1* - Compares the sample and result files.
* *Debug-Error.ps1* - Enables debugging on terminating errors.
* *Expand-Diff.ps1* - Expands git diff into directories "a" and "b".
* *Export-Binary.ps1* - Exports objects using binary serialization.
* *Format-Chart.ps1* - Formats output as a table with the last chart column.
* *Format-High.ps1* - Formats output by columns with optional custom item colors.
* *Import-Binary.ps1* - Imports objects using binary serialization.
* *Invoke-Environment.ps1* - Invokes a command and imports its environment variables.
* *Invoke-Ngen.ps1* - Invokes the Native Image Generator tool (ngen.exe).
* *Invoke-PowerShell.ps1* - Invokes PowerShell of the currently running version.
* *Measure-Command2.ps1* - Measure-Command with several iterations and progress.
* *Measure-Property.ps1* -  Counts properties grouped by names and types.
* *Save-NuGetTool.ps1* - Downloads a NuGet package and extracts /tools.
* *Set-ConsoleSize.ps1* - Sets the current console size, interactively by default.
* *Set-Env.ArgumentCompleters.ps1* - Completes Set-Env.ps1 -Name .
* *Set-Env.ps1* - Sets or removes environment variables (Windows User/Machine).
* *Show-Color.ps1* - Shows all color combinations, color names and codes.
* *Show-Coverage.ps1* - Converts to HTML and shows script coverage data.
* *Show-GraphQLVoyager.ps1* - Shows GraphQL schema using GraphQL Voyager.
* *Show-SolutionDgml.ps1* - Generates and shows the solution project graph.
* *Submit-Gist.ps1* - Submits a file to its GitHub gist repository.
* *Sync-Directory.ps1* - Syncs two directories with some interaction.
* *Test-Debugger.ps1* - Tests PowerShell debugging with breakpoints.
* *Trace-Debugger.ps1* - Provides script tracing and coverage data collection.
* *Update-Gist.ps1* - Updates or creates a gist file using Invoke-RestMethod.
* *Update-ReadmeIndex.ps1* - Updates README index from content directories.
* *Watch-Command.ps1* - Invokes a command repeatedly and shows its one screen output.
* *Watch-Directory.ps1* - File change watcher and handler.

## Get Scripts

Some scripts are available at [PSGallery](https://www.powershellgallery.com/)
and all scripts are published as the NuGet package [PowerShelf](https://www.nuget.org/packages/PowerShelf).

You may download all scripts by this command:

```powershell
iex "& {$(irm https://raw.githubusercontent.com/nightroman/PowerShelf/main/Save-NuGetTool.ps1)} PowerShelf"
```

## See Also

- [PowerShelf Release Notes](https://github.com/nightroman/PowerShelf/blob/main/Pack/Release-Notes.md)
