   <?php 
   include("conn.php"); 
   //error_reporting(0);
   ob_start();
   session_start(); 
   require 'phpspreadsheet/vendor/autoload.php';

   use PhpOffice\PhpSpreadsheet\Spreadsheet;
   use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
   if(isset(($_POST['btnSubmit']))){
    $time=date("H:i:s");
$filename=$_FILES['pricesheet']['name'];
$file_ext=pathinfo($filename,PATHINFO_EXTENSION);

$allow_ext=['xls','csv','xlsx'];

if(in_array($file_ext,$allow_ext)){
  $inputFileNamePath=$_FILES['pricesheet']['tmp_name'];
  $spreadsheet = \PhpOffice\PhpSpreadsheet\IOFactory::load($inputFileNamePath);
$data = $spreadsheet->getActiveSheet() -> toArray();

$count="0";
foreach($data as $row){
  if($count > 0){
    $PriceDate = $row['0'];
    $Company = $row['1'];
    $BidPrice = $row['2'];
    $OfferPrice = $row['3'];
    $Price = $row['4'];
  
    $query="INSERT INTO counterprices 
    (ShortName,BidPrice,OfferPrice,Price,PriceDate,DateCreated,Time) VALUES ('$Company','$BidPrice','$OfferPrice','$Price','$PriceDate',curdate(),'$time')";
    $res = mysqli_query($connection,  $query);
    $msg=true;
  }
 else{
  $count="1";
 }
 

}
if(isset($msg)){
  echo "<script> alert('Price Sheet has been successfully Imported');window.location='CounterPriceUpload.php';</script>";
 
}
else{
  echo "<script> alert('Price Sheet Not imported');window.location='CounterPriceUpload.php';</script> ";

}

}
else{
  echo "<script> alert('Invalid file');window.location='CounterPriceUpload.php';</script>";

}
   }
   ?>
   
   