<?php
include("conn.php");

ob_start();
session_start(); 

if(isset($_POST['postcounter'])){
	$Countername=$_POST['postcounter'];
	
	if (isset($Countername))
	{
		$newsql="Select Price from `counterprices` where ShortName='$Countername' ";
	$myquery = $connection->query($newsql);
	while($row = $myquery->fetch_assoc())
		{
			$_SESSION['Price']=$row['Price'];
  if(isset($_SESSION['Price'])){echo $_SESSION['Price']; }
		}
	}
}
	
	
?>