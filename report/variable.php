<?php

class Variable {
    public static $raceClass = "Race Class";
    public static $track = "Track Category";
    public static $barrier = "Barrier";
    public static $state = "State / Area";
    public static $WFA = "WFA";
    public static $sex = "Sex";
    public static $DOW = "DOW";
	public static $prise = "Prise Money";
	public static $trackCond = "Track Condition";
	public static $dayPreStart = "Day Since Previous Start";

	function getVariables()
    {
        $class = new ReflectionClass('Variable');
        $arr = $class->getStaticProperties();
	    return array_values($arr);
    }
}

?>