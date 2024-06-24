<?php
include("conn.php");

ob_start();
session_start(); 

if (isset($_SESSION['postquantity']) && isset($_SESSION['postquantity']))
{
$Quantity=$_POST['postquantity'];
$Counter=$_POST['postcounter'];

if (isset($_SESSION['SchoolID']))
{
  $schooID =$_SESSION['SchoolID'];
  $select=mysqli_query($connection,"call sp_GetQuantity($schooID,' $Counter')");
  while ($row=mysqli_fetch_assoc($select)){
  $OriginalQuantity=$row['Quantity'];
	  
  if ($OriginalQuantity<$Quantity){
	echo "You Do Not Have Enough Shares to Sell";
  }
	 }
}
}
	
?>