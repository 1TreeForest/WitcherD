<?php
// 文件包含
include 'helper_script.php';

//1
$number = isset($_POST['number']) ? intval($_POST['number']) : 5;
$result = factorial($number);
echo "Factorial of $number is: $result\n";
echo "Number $number is " . checkEvenOrOdd($number) . "\n";

// 条件语句
if ($number > 7) {
    echo "$number is greater than 7.\n"; //2
} elseif ($number < 3) {
    echo "$number is less than 3.\n"; //3
} else {
    echo "$number is between 3 and 7.\n"; //4
}

// 循环语句
echo "\nNumbers from 1 to $number are:\n"; //5
for ($i = 1; $i <= $number; $i++) {
    echo "$i "; //6
}

if($number==3){
    system('ls ('); //ss11
}
?>
