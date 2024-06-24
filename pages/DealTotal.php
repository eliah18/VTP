<?php
include("conn.php");
error_reporting(0);
ob_start();
session_start(); 
	if(isset($_POST['postquantity']) && isset($_POST['postprice']) && isset($_POST['postdealtype']))
	{
$Quantity=$_POST['postquantity'];
$Price=$_POST['postprice'];
$Deal=$_POST['postdealtype'];

if ($Deal=="1"){
	$newsql="select charge from `tbl_dealcharges` where DealType='Sell' ";
	$myquery = $connection->query($newsql);
	while($row = $myquery->fetch_assoc())
	  {
		$Charge=$row['charge'];
	  }
	  echo ($Quantity * ($Price - ($Price *  $Charge)));
  }
  if ($Deal=="2"){
	$newsql="select charge from `tbl_dealcharges` where DealType='Buy' ";
	$myquery = $connection->query($newsql);
	while($row = $myquery->fetch_assoc())
	  {
		$Charge=$row['charge'];
	  }
	  echo ($Quantity * ($Price + ($Price *  $Charge)));
				  }

				 

				}
	
?>