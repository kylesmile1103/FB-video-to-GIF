Add-Type -AssemblyName PresentationFramework | Out-Null
Add-Type -AssemblyName System.Drawing | Out-Null
Add-Type -AssemblyName System.Windows.Forms | Out-Null
Add-Type -AssemblyName WindowsFormsIntegration | Out-Null
[void][System.Windows.Forms.Application]::EnableVisualStyles()
[Console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8bom'
$wshell = New-Object -ComObject Wscript.Shell

[Xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" Title="Convert Facebook video to GIF" MinHeight="220" MinWidth="800">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <Grid Grid.Row="0" VerticalAlignment="Top" HorizontalAlignment="Right">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*" />
                <ColumnDefinition Width="*" />
            </Grid.ColumnDefinitions>
            <Grid Grid.Column="0" Margin="10">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="*" />
                </Grid.ColumnDefinitions>
                <Viewbox Width="24" Height="24" Grid.Column="0">
                    <Canvas Width="24" Height="24">
                        <Path x:Name="ffmpeg" Fill="Green" Data="M10,17L5,12L6.41,10.58L10,14.17L17.59,6.58L19,8M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z" />
                    </Canvas>
                </Viewbox>
                <Label FontWeight="bold" Grid.Column="1" Content="FFMPEG Package" />
                <Button Grid.Column="2" Width="80" Height="28" Content="Install" x:Name="insFFmpegBtn"/>
            </Grid>
            <Grid Grid.Column="1" Margin="10">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="*" />
                </Grid.ColumnDefinitions>
                <Viewbox Width="24" Height="24" Grid.Column="0">
                    <Canvas Width="24" Height="24">
                        <Path x:Name="youtubedl" Fill="Green" Data="M10,17L5,12L6.41,10.58L10,14.17L17.59,6.58L19,8M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z" />
                    </Canvas>
                </Viewbox>
                <Label FontWeight="bold" Grid.Column="1" Content="Youtube-dl Package" />
                <Button Grid.Column="2" Width="80" Height="28" Content="Install" x:Name="insYoutubeDlBtn"/>
            </Grid>
        </Grid>
        <Grid Grid.Row="1">
            <GroupBox Header="Input" FlowDirection="RightToLeft" Margin="8,8,4,4" HorizontalAlignment="Stretch" VerticalAlignment="Stretch">
                <Grid FlowDirection="LeftToRight" Margin="5">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto" />
                        <ColumnDefinition Width="*" />
                    </Grid.ColumnDefinitions>
                    <Label Grid.Column="0" Content="Facebook Post URL:" />
                    <TextBox x:Name="postURL" Grid.Column="1" Margin="5,0,0,0" VerticalAlignment="Center" HorizontalAlignment="Stretch" TextWrapping="Wrap"/>
                </Grid>
            </GroupBox>
        </Grid>
        <Grid Grid.Row="2" HorizontalAlignment="Center">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*" />
                <ColumnDefinition Width="*" />
            </Grid.ColumnDefinitions>
            <Button Margin="15" Grid.Column="0" Width="200" Height="28" Content="DOWNLOAD VIDEO" x:Name="downloadBtn"/>
            <Button Margin="15" Grid.Column="1" Width="200" Height="28" Content="DOWNLOAD AND CONVERT TO GIF" x:Name="downConvertBtn"/>
        </Grid>
    </Grid>
</Window>
"@

$Window = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $xaml))
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object -Process {
    Set-Variable -Name ($_.Name) -Value $window.FindName($_.Name) -Scope Script
}

$splScr = [hashtable]::Synchronized(@{})
$runspace = [runspacefactory]::CreateRunspace()
$runspace.ApartmentState = [System.Threading.ApartmentState]::STA
$runspace.ThreadOptions = "ReuseThread"
$runspace.Open()
$runspace.SessionStateProxy.SetVariable("splScr", $splScr)
$Pwshell = [PowerShell]::Create()

function Start-SplashScreen () {
    $Pwshell.Runspace = $runspace
    $script:handle = $Pwshell.BeginInvoke()
}

function Close-SplashScreen () {
    $splScr.window.Dispatcher.Invoke("Normal", [action] { $splScr.window.close() })
    $Pwshell.EndInvoke($handle) | Out-Null
}

$sendToRunspace = {
    [xml]$xaml2 = @"
<Window
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
x:Name="WindowSplash" Title="Loading Splashscreen" WindowStyle="None" WindowStartupLocation="CenterScreen"
Background="CornFlowerBlue" ShowInTaskbar ="false" 
Width="600" Height="300" ResizeMode = "NoResize" Topmost="True" >
<Grid>
   <Grid.RowDefinitions>
       <RowDefinition Height="70"/>
       <RowDefinition/>
       <RowDefinition/>
   </Grid.RowDefinitions>
   <Grid Grid.Row="0" x:Name="Header" >	
       <StackPanel Orientation="Horizontal" HorizontalAlignment="Left" VerticalAlignment="Stretch" Margin="20,10,0,0">       
           <Label Content="Convert Facebook video to GIF" Margin="5,0,0,0" Foreground="White" Height="50"  FontSize="30"/>
       </StackPanel> 
   </Grid>
   <Grid Grid.Row="1" >
        <StackPanel Orientation="Vertical" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="5,5,5,5">
           <Label x:Name="LoadingLabel" Content="LOADING" Foreground="White" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="24" Margin = "0,0,0,0"/>
       </StackPanel>	
   </Grid>
   <TextBlock Grid.Row="2"
  Name="loadingDots"
  Margin="20" 
  Width="600" Height="Auto" FontSize="25" FontWeight="Bold" Foreground="White">
  ................................................................
  <TextBlock.Triggers>
    <EventTrigger RoutedEvent="TextBlock.Loaded">
      <BeginStoryboard>
        <Storyboard>
          <DoubleAnimation
            Storyboard.TargetName="loadingDots" 
            Storyboard.TargetProperty="(TextBlock.Width)"
            To="0.0" Duration="0:0:3" 
            AutoReverse="True" RepeatBehavior="Forever" />
        </Storyboard>
      </BeginStoryboard>
    </EventTrigger>
  </TextBlock.Triggers>
</TextBlock>
</Grid>
</Window> 
"@    
    $global:SSreader = New-Object System.Xml.XmlNodeReader $xaml2
    $global:splScr.window = [Windows.Markup.XamlReader]::Load($SSreader)
    $splScr.window.ShowDialog()
    $splScr.window.Activate()
}
$Pwshell.AddScript($sendToRunspace)

Start-SplashScreen

function checkCommand($cmd) {
    return !!$(Get-Command -errorAction SilentlyContinue $cmd);
}
function checkAdminPrivileges {
    $isAdmin = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    return $isAdmin.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Install-ChocoPkg ($pkg, $opt) {
    Start-SplashScreen
    if (. checkCommand "choco") {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    [array]$chocoCMD = "choco", "install", $pkg, "-y", "--force", $opt
    Invoke-Expression("$chocoCMD")
    Close-SplashScreen
    if ( $LastExitCode -ne 0 ) {
        $wshell.Popup("$($pkg.ToUpper()) installation failed!", 0, "ERROR")
    }
    else {
        $wshell.Popup("$($pkg.ToUpper()) is installed with the latest version!", 0, "SUCCESSFUL")
    }
}

function Get-FilePath($typeDialogs) {
    \
    $OpenFileDialog = New-Object 'System.Windows.Forms.SaveFileDialog'
    if ($typeDialogs -eq "video") {
        $OpenFileDialog.DefaultExt = "mp4"
        $OpenFileDialog.Filter = "Video format (*.mp4) |*.mp4; *.wmv; *.3g2; *.3gp; *.3gp2; *.3gpp; *.amv; *.asf;  *.avi; *.bin; *.cue; *.divx; *.dv; *.flv; *.gxf; *.iso; *.m1v; *.m2v; *.m2t; *.m2ts; *.m4v; " +
        " *.mkv; *.mov; *.mp2; *.mp2v; *.mp4; *.mp4v; *.mpa; *.mpe; *.mpeg; *.mpeg1; *.mpeg2; *.mpeg4; *.mpg; *.mpv2; *.mts; *.nsv; *.nuv; *.ogg; *.ogm; *.ogv; *.ogx; *.ps; *.rec; *.rm; *.rmvb; *.tod; *.ts; *.tts; *.vob; *.vro; *.webm"
    }
    elseif ($typeDialogs -eq "gif") {
        $OpenFileDialog.DefaultExt = "gif"
        $OpenFileDialog.Filter = "GIF format (*.gif)|*.gif"
    }
    $OpenFileDialog.title = "Save file to..."
    if ($OpenFileDialog.ShowDialog() -eq 'Ok') {
        Write-Output $OpenFileDialog.FileName
    }
}

function ffmpegProcess ([string]$inputs, [string]$opt, [string]$output) {
    [array]$ffmpegCMD = 'ffmpeg', '-y', '-i', $inputs,
    $opt, $output, '-stats -hide_banner -loglevel quiet', ";cmd /c", "explorer", "/select,$output"
    try {
        Invoke-Expression("$ffmpegCMD");
        Close-SplashScreen
    }
    catch {
        Close-SplashScreen
        $wshell.Popup("Download failed!", 0, "ERROR")
    }
    # $wshell.Popup("$ffmpegCMD", 0, "DEBUG")
}

$warnBadge = "M12,2C17.53,2 22,6.47 22,12C22,17.53 17.53,22 12,22C6.47,22 2,17.53 2,12C2,6.47 6.47,2 12,2M15.59,7L12,10.59L8.41,7L7,8.41L10.59,12L7,15.59L8.41,17L12,13.41L15.59,17L17,15.59L13.41,12L17,8.41L15.59,7Z"
$checkBadge = "M10,17L5,12L6.41,10.58L10,14.17L17.59,6.58L19,8M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z"
if (!(. checkCommand "ffmpeg")) {
    $ffmpeg.fill = "Red"
    $ffmpeg.Data = $warnBadge
}
else {
    $insFFmpegBtn.Content = "Reinstall"
}
if (!(. checkCommand "youtube-dl")) {
    $youtubedl.fill = "Red"
    $youtubedl.Data = $warnBadge
}
else {
    $insYoutubeDlBtn.Content = "Reinstall"
}

$insFFmpegBtn.Add_Click( {
        if (checkAdminPrivileges -ne $false) {
            Install-ChocoPkg "ffmpeg"
            if (. checkCommand "ffmpeg") {
                $this.Content = "Reinstall"
                $ffmpeg.fill = "Green"
                $ffmpeg.Data = $checkBadge
            }
        }
        else {
            $wshell.Popup("Run as Administrator privileges to install these packages!", 0, "ERROR")
        }
    })

$insYoutubeDlBtn.Add_Click( {
        if (checkAdminPrivileges -ne $false) {
            Install-ChocoPkg "youtube-dl"
            if (. checkCommand "youtube-dl") {
                $this.Content = "Reinstall"
                $youtubedl.fill = "Green"
                $youtubedl.Data = $checkBadge
            }
        }
        else {
            $wshell.Popup("Run as Administrator privileges to install these packages!", 0, "ERROR")
        }
    })

$downloadBtn.Add_Click( {
        [String]$videoFile = Get-FilePath "video"
        if (![string]::IsNullOrEmpty($videoFile)) {
            Start-SplashScreen
            $rawUrl = '"{0}"' -f $postURL.Text
            $vidUrl = '"{0}"' -f $(youtube-dl -g $rawUrl)
            ffmpegProcess $vidUrl "" $('"{0}"' -f $videoFile)
        }
    })

$downConvertBtn.Add_Click( {
        $gifFile = Get-FilePath "gif"
        if (![string]::IsNullOrEmpty($gifFile)) {
            Start-SplashScreen
            $rawUrl = '"{0}"' -f $postURL.Text
            $vidUrl = '"{0}"' -f $(youtube-dl -g $rawUrl)
            ffmpegProcess $vidUrl "" ('"{0}"' -f $gifFile)
        }
    })

$window.Add_Closing( { [System.Windows.Forms.Application]::Exit(); Stop-Process $pid })
$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);' 
$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru 
$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
[System.Windows.Forms.Integration.ElementHost]::EnableModelessKeyboardInterop($window)
$window.Show()
$window.Activate()
Close-SplashScreen

$appContext = New-Object System.Windows.Forms.ApplicationContext 
[void][System.Windows.Forms.Application]::Run($appContext)