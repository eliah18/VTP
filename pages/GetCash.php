<?php
include("conn.php");

ob_start();
session_start(); 


	
	if (isset($_SESSION['UserID']))
	{
		$UserID=$_SESSION['UserID'];
		$newsql="call sp_ValidateDealCash('$UserID') ";
	$myquery = $connection->query($newsql);
	while($row = $myquery->fetch_assoc())
		{
			$_SESSION['CashValue']=$row['CashValue'];
  if(isset($_SESSION['CashValue'])){echo $_SESSION['CashValue']; }
		}
	}

	
	
?>