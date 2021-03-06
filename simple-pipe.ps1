
function get-chunk ($delim="-", $size=3){
                begin{$group=@();} 
                process{$group+=$_; if ($group.Count -eq $size) { write-output $([string]::Join($delim,$group)); $group=@()} } 
                end{write-output $([string]::Join($delim,$group))} 
              } 
function get-logentry ($delim="`r`n", $match="^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}"){
                begin{$group=@();} 
                process{ $item=$_; if ($item -match $match) { if ($group) { write-output $([string]::Join($delim,$group)) } $group=@($item)} else { $group+=$_}} 
                end{write-output $([string]::Join($delim,$group))} 
              } 
function write-count{  begin { $line = 0}   process { ++$line;  write-output "$line `t: $_"} } 
function split ($delim=",") { process { write-output $($_.split($delim)) } }
function join ($delim=",",$group=@()) { write-output $([string]::Join($delim,$group))}
function get-logobject{
     process{ 
        $logentry = [string]::Format($_);
        $items = $logentry.split("|"); 
        $entry = [string]::Join("|",$items[2..$($items.length-1)]); 
        $object = New-Object –TypeName PSObject –Property (@{
           "DateTime"=[DateTime]::ParseExact($items[0],"yyyy-MM-dd HH:mm:ss.ffff",$null);
           "LogLevel"=$items[1];
           "Xml"=[Xml] $entry;
           "Raw"=$logentry;
          })
        Write-Output $object
      } 
}
  1..14 | & get-chunk | write-count
  "----"
  1..14 | & get-chunk | & get-chunk -delim "="  | write-count
  "----"
  1..14 | & get-chunk | & get-chunk -delim "=" | & split -delim "-="  | write-count

  $logEntries  = @"
2017-07-15 19:46:12.0212|INFO|<Group reference="12345"><Name>Beatles</Name>
   <Members>
    <Member>Paul</Member>
    <Member>John</Member>
    <Member>Ringo</Member>
    <Member>George</Member>
   </Members>
</Group>
2017-07-15 19:46:12.3312|INFO|<Group reference="21345"><Name>A-Team</Name>
   <Members>
    <Member>Hannibal</Member>
    <Member>Face</Member>
    <Member>BA</Member>
    <Member>Murdoch</Member>
   </Members>
</Group>
"@
$lines | Out-File .\lines.txt
$logEntries | Out-File .\logentries.log
Get-Content .\logentries.log | write-count 
Get-Content .\logentries.log | & get-chunk -delim "`r`n" |  write-count
Get-Content .\logentries.log | & get-logentry -delim "`r`n" | write-count
#foreach-object {"<<< $_ >>>"}
Get-Content .\logentries.log | & get-logentry -delim "`r`n" | Select-String "21345" | write-count
Get-Content .\logentries.log | & get-logentry -delim "`r`n" | Select-String "21345" | get-logobject | get-member
Get-Content .\logentries.log | & get-logentry -delim "`r`n" | Select-String "21345" | get-logobject | %{ $_.DateTime.DateTime,$_.Xml.Group.Name,[string]::Join(",",$_.Xml.Group.Members.Member) }


