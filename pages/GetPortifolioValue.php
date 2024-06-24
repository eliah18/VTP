<?php
include("conn.php");

ob_start();
session_start(); 


	
if (isset($_SESSION['UserID']))
{
	$UserID=$_SESSION['UserID'];
	$newsql="call sp_GetPortfolioValue('$UserID') ";
	$myquery = $connection->query($newsql);
	while($row = $myquery->fetch_assoc())
		{
			$_SESSION['PortfolioValue']=$row['PortfolioValue'];
  if(isset($_SESSION['PortfolioValue'])){echo $_SESSION['PortfolioValue']; }
		}
	}

	
	
?>