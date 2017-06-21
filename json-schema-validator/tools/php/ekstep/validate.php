<?php
//config
$schemaPath = __DIR__ . '/../../../schema/v4/';	//must end with trailing slash

//Formatting constants
const FORMAT_ESC = 			"\033[";
const FORMAT_COLOR_RED = 	FORMAT_ESC . "31m";
const FORMAT_COLOR_GREEN =	FORMAT_ESC . "32m";
const FORMAT_COLOR_YELLOW =	FORMAT_ESC . "33m";
const FORMAT_COLOR_BLUE = 	FORMAT_ESC . "34m";
const FORMAT_COLOR_PURPLE = FORMAT_ESC . "35m";
const FORMAT_COLOR_CYAN = 	FORMAT_ESC . "36m";
const FORMAT_COLOR_GRAY = 	FORMAT_ESC . "37m";
const FORMAT_COLOR_END = 	FORMAT_ESC . "0m";

const FORMAT_LINE_BREAK 	= "\n";
const FORMAT_LINE_SEPARATOR = FORMAT_COLOR_GRAY . "\n\n*******************************************\n" . FORMAT_COLOR_END;


require __DIR__ . '/../vendor/autoload.php';

if ((isset($argv[1]) && $argv[1])) {
	$dataFile = $argv[1];
} else {
	echo FORMAT_COLOR_RED . "Error: No data file provided. Please provide the path to the JSON file to be validated." . FORMAT_COLOR_END . FORMAT_LINE_BREAK;
}

$timer[] = microtime(true);
$dataHandle = fopen($dataFile, "r");
if ($dataHandle) {

	$lineNumber = 0;
	$errorCount = 0;
	$nonSchemaErrorCount = 0;
    while (($line = fgets($dataHandle)) !== false) {
    	$lineNumber++;

    	//display progress
		$progress = number_format($lineNumber);
		$progress_formatted = str_pad($progress, 10, ' ', STR_PAD_LEFT) . " records";
		echo "\033[32D";	//move back the cursor
		echo FORMAT_COLOR_YELLOW . "Progress:   " . $progress_formatted . FORMAT_COLOR_END;

        $lineData = json_decode($line);

        $eventType = $lineData->eid;
		$schemaFile = strtolower($eventType) . '.json';
		$schema = $schemaPath.$schemaFile;

		if(!file_exists(realpath($schema))) {
			$nonSchemaErrorCount++;
		    echo FORMAT_LINE_SEPARATOR . FORMAT_COLOR_YELLOW . "JSON [$eventType] at line: {$lineNumber} cannot be validated because of non-availability of schema. Please ensure you have '{$schemaFile}' available and readable at '".realpath($schemaPath)."'" . FORMAT_COLOR_END . FORMAT_LINE_BREAK;
		    continue;
		}

		// Validate
		$validator = new JsonSchema\Validator();
		$validator->check($lineData, (object) array('$ref' => 'file://' . $schema));

		if ($validator->isValid()) {
			// UNCOMMENT Below line to display positive messages as well.
		    // echo "The supplied JSON [$eventType] validates against the schema.\n";
		} else {
			$errorCount++;
		    echo FORMAT_LINE_SEPARATOR . FORMAT_COLOR_RED . "JSON [$eventType] at line: {$lineNumber} does not validate." . FORMAT_LINE_BREAK . FORMAT_COLOR_CYAN . "Provided Data: $line " . FORMAT_LINE_BREAK .
		    	FORMAT_COLOR_RED . "Violations:" . FORMAT_LINE_BREAK;
		    foreach ($validator->getErrors() as $error) {
		        echo sprintf("[%s] %s" . FORMAT_LINE_BREAK, $error['property'], $error['message']);
		    }
		    echo FORMAT_COLOR_END;
		}
    }

    //update color of last progress.
	echo "\033[32D";	//move back the cursor
	echo FORMAT_COLOR_GREEN . "Progress:   " . $progress_formatted . FORMAT_COLOR_END . FORMAT_LINE_BREAK;


    if ($errorCount) {
    	echo FORMAT_LINE_BREAK . FORMAT_COLOR_RED . "Found error(s) in $errorCount record(s)." . FORMAT_COLOR_END . FORMAT_LINE_BREAK;
    } else {
    	echo FORMAT_LINE_BREAK . FORMAT_COLOR_GREEN . "No errors found!" . FORMAT_COLOR_END . FORMAT_LINE_BREAK;
    }

    if ($nonSchemaErrorCount) {
    	echo FORMAT_LINE_BREAK . FORMAT_COLOR_YELLOW . "WARNING: Could not validate $nonSchemaErrorCount records - Schema not available." . FORMAT_COLOR_END . FORMAT_LINE_BREAK;
    } else {
    	echo FORMAT_LINE_BREAK . FORMAT_COLOR_GREEN . "No warnings generated!" . FORMAT_COLOR_END . FORMAT_LINE_BREAK;
    }

    echo FORMAT_LINE_BREAK . FORMAT_COLOR_GREEN . "INFO: Completed validating $lineNumber record(s)." . FORMAT_COLOR_END . FORMAT_LINE_BREAK;

    fclose($dataHandle);
} else {
    echo FORMAT_LINE_BREAK . FORMAT_COLOR_RED . "Error: Could not read data file. Please ensure the file path is valid and readable." . FORMAT_COLOR_END . FORMAT_LINE_BREAK;
}

$timer[] = microtime(true);
$diff = end($timer) - prev($timer);
$timetaken = number_format($diff, 6);
echo FORMAT_COLOR_GREEN . "INFO: Task completed in " . FORMAT_COLOR_PURPLE . $timetaken . FORMAT_COLOR_END . "s" . FORMAT_LINE_BREAK . FORMAT_LINE_BREAK;