<?php
include("conn.php");

ob_start();
session_start(); 


		$newsql="call sp_GetCashValue('$UserID') ";
	$myquery = $connection->query($newsql);
	while($row = $myquery->fetch_assoc())
		{
			$_SESSION['CashValue']=$row['CashValue'];
  if(isset($_SESSION['CashValue'])){echo $_SESSION['CashValue']; }
		}


	
	
?>