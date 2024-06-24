<?php
include("conn.php");

ob_start();
session_start(); 

if (isset($_SESSION['SchoolName']))
{
	$xul_name=$_SESSION['SchoolName'];
	$newsql="call GetRank('$xul_name') ";
	$myquery = $connection->query($newsql);
	while($row = $myquery->fetch_assoc())
		{
			$_SESSION['ID']=$row['ID'];
  if(isset($_SESSION['ID'])){echo $_SESSION['ID']; }
		}
	
	}

	
	
?>