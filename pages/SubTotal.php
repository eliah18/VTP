<?php
include("conn.php");
error_reporting(0);
ob_start();
session_start(); 
	if(isset($_POST['postquantity']) && isset($_POST['postprice']) )
	{
	$Quantity=$_POST['postquantity'];
	$Price=$_POST['postprice'];
	echo ($Quantity * $Price);

	}
?>