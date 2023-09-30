<?php
// 文件包含
include 'helper_script.php';

//1
$number = isset($_POST['number']) ? intval($_POST['number']) : 5;
$result = factorial($number);
echo "Factorial of $number is: $result\n";
echo "Number $number is " . checkEvenOrOdd($number) . "\n";

// if test
if ($number > 7) {
    echo "$number is greater than 7.\n"; //2
} elseif ($number < 3) {
    echo "$number is less than 3.\n"; //3
} else {
    echo "$number is between 3 and 7.\n"; //4
}

// for test
echo "\nNumbers from 1 to $number are:\n"; //5
for ($i = 1; $i <= $number; $i++) {
    echo "$i "; //6
}

$test_while = 3;
while ($test_while > 0) {
    echo "\n$test_while "; //7
    $test_while--;
}

if($number == 3){
    system('ls ('); //ss11
}
?>
