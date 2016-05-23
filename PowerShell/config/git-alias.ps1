############################################
############# Creating Array of all commands

$myCommands = New-Object System.Collections.ArrayList

function AddGitAlias([string] $alias,
    [string] $commandText,
    [string] $command,
    [string] $description){
    $myCommands.Add([pscustomobject] @{
        alias="$alias";
        commandText="$commandText";
        command=$command;
        description=$description}) `
    > $null
}

############################################
########### Defining commands ############

$gitStatusCmd =  ' git status '
function git-status {
    Write-Command $gitStatusCmd
    Invoke-Expression $gitStatusCmd
}
AddGitAlias "ggs" "$gitStatusCmd" "git-status"


$gitDiffCmd = 'git diff'
function git-diff {
    Write-Info "git diff"
    iex $gitDiffCmd
    git diff --staged
}
AddGitAlias "ggd" $gitDiffCmd "git-diff" "show changes in files"


$gitBranchNameCmd = ' git rev-parse --abbrev-ref HEAD '
function git-branchName { iex $gitBranchNameCmd }


$gitAddCmd = 'git add .'
$gitCommitCmd = 'git commit -m "{0}"'
$gitAddAndCommitDesc = "Adding all unstaged files to stage,  Commiting staged files... "
function git-commit ([string] $message){
    if(!$message){
        Write-Err "Please provide a message for the commit !!!"
        return
    }
    Write-Info $gitAddAndCommitDesc
    Write-Command $gitAddCmd
    iex $gitAddCmd

    Write-Command ($gitCommitCmd -f $message)
    iex ($gitCommitCmd -f $message)
}
AddGitAlias "ggc" $gitCommitCmd  "git-commit" $gitAddAndCommitDesc


$gitResetCmd = 'git reset HEAD --hard'
$gitResetDesc =  "Unstaging all staged changes "
Function git-reset {
    Write-Info $gitResetDesc
    Write-Command $gitResetCmd
    iex $gitResetCmd
}
AddGitAlias "ggrst" $gitResetCmd "git-reset" $gitResetDesc

#######################################
#####  CHECKOUT

$gitCheckoutCmd = 'git checkout {0}'
$gitCheckoutDesc = "Switching to branch {0}"
function git-checkout([string] $branchName) {
    IF(!$branchName){
        $branchName = git-branchName
    }
    Write-Info ($gitCheckoutDesc -f $branchName)
    Write-Command ($gitCheckoutCmd -f $branchName)
    iex ($gitCheckoutCmd -f $branchName)

    git-pull
}
AddGitAlias "ggch"  $gitCheckoutCmd  "git-checkout" $gitCheckoutDesc


function git-checkoutStar {
    git-checkout "*"
}
AddGitAlias "ggcs"  $gitCheckoutCmd  "git-checkoutStar" $gitCheckoutDesc


function git-checkoutWork {
    git-checkout "work"
}
AddGitAlias "ggw" $gitCheckoutCmd "git-checkoutWork" $gitCheckoutDesc


function git-checkoutMaster {
    git-checkout "master"
}
AddGitAlias "ggm" $gitCheckoutCmd "git-checkoutMaster" $gitCheckoutDesc

################################################

$gitCleanCmd = 'git clean -fd'
$gitCleanDescription =  "Cleaning all untracked changes in files / directories / ignored."
function git-clean {
    Write-Info $gitCleanDescription
    Write-Command $gitCleanCmd
    iex $gitCleanCmd
}
AddGitAlias "ggcln" $gitCleanCmd "git-clean" $gitCleanDescription


$gitRevertAllDesc = "Reverting all changes in current working directory (staged, unstaged, tracked, untracked, ignored)"
function git-revertAll {
    Write-Info $gitRevertAllDesc
    git-reset
    git-checkout
    git-clean
}
AddGitAlias "ggrevert" "$gitResetCmd ; $gitCheckoutStarCmd ; $gitCleanCmd " "git-revertAll" $gitRevertAllDesc


$gitUndoLastCommitCmd = 'git reset HEAD^'
function git-undoLastCommit {
    Write-Info "Undoing last commit, moving HEAD one step behind"
    Write-Command $gitUndoLastCommitCmd

    iex $gitUndoLastCommitCmd
}
AddGitAlias "ggundo" $gitUndoLastCommitCmd  "git-undoLastCommit"


$gitPushCmd = 'git push origin {0}'
$gitPushDesc =  "Pushing changes from current branch to origin."
function git-push () {
    $branchName = git-branchName
    Write-Info $gitPushDesc
    Write-Command ($gitPushCmd -f $branchName)
    iex ($gitPushCmd -f $branchName)
}
AddGitAlias "ggp" $gitPushCmd  "git-push" $gitPushDesc


$gitPullCmd = 'git pull origin {0}'
$gitPullDesc =  "Pulling changes from origin to current branch "
function git-pull () {
    $branchName = git-branchName
    Write-Info $gitPullDesc
    Write-Command ($gitPullCmd -f $branchName)
    iex ($gitPullCmd -f $branchName)
}
AddGitAlias "ggu" $gitPullCmd  "git-pull" $gitPullDesc


$gitHistoryCmd = 'git log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate'
Function git-history([number] $lastNCommits = 20){
    Write-Info "Getting history "
    Write-Command $gitHistoryCmd
    iex $gitHistoryCmd | Select -First $lastNCommits
}
AddGitAlias "ggh" $gitHistoryCmd "git-history"


$gitSaveDesc = "Save current work with generic message"
Function git-save{
    $time = Get-Date -format u
    git-commit "Save at $time"
}
AddGitAlias "ggv" $gitCommitCmd "git-save" $gitSaveDesc


function git-grep ([string] $pattern) { git grep $pattern }

function git-all()
{
	$s = $global:GitAllSettings
	dir -r -i .git -fo | % {
		pushd $_.fullname
		cd ..
		write-host -fore $s.FolderForegroundColor (get-location).Path
		git-fetchall
		popd
	}
}

function git-fetchall()
{
	$remotes = git remote

	if($remotes){
		$remotes | foreach {
			Write-Host 'Fetching from' $_
			git fetch $_ --all
		}
	}else{
		Write-Host 'No remotes for this repository'
	}
	git status
}

# git log man : https://git-scm.com/docs/git-log
# Format options :
# %d: ref names, like the --decorate option of git-log[1] - branch names
# %ar: author date, relative
# %h: abbreviated commit hash
# %s: subject - commit message
# %an: author name - of a commit
$gitLogGraphCmd = "git log --graph " +
    "--abbrev-commit " +
    "--decorate "+
    "--format=format:'" +
        "%C(bold yellow)%d%C(reset) " +       # branch name
        "%n      " +                          # new line
        "%C(bold green)(%ar)%C(reset) " +     # date of commit
        "%C(dim white) [%an]%C(reset) - " +   # author name
        "%C(white)%s%C(reset) " +             # commit message
        "%C(bold blue)[%h]%C(reset)" +        # short hash of commit
        "' --all"
$gitLogGraphDesc = "Getting branch tree "
function git-logGraph(){
    Write-Info $gitLogGraphDesc
    iex $gitLogGraphCmd
}
AddGitAlias "ggb" $gitLogGraphCmd "git-logGraph" $gitLogGraphDesc


####### Import Cogworks specific commands  ####
. ($PScriptConfig + "\cogworks-git-alias.ps1")
################################################


# Help function
function MyGitHelp(){
    Write-Info "My git commands"
    $myCommands `
        | Sort-Object Alias `
        | ForEach {
        "`t" + $_.alias +
        "`t- " + $_.description +
        "`n`t`t" + $_.commandText +
        "`n"}
}
AddGitAlias "gghelp" "Displays this help text" "MyGitHelp"


# Setting Aliases
$myCommands | ForEach { Set-Alias -Name $_.alias -Value $_.command }


