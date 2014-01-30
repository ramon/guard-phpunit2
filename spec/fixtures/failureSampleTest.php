<?php

class Fail2 extends PHPUnit_Framework_TestCase {
  public function testTrueIsTrue() {
    $this->assertTrue(false);
  }

  public function testFalseIsFalse() {
    $this->assertFalse(true);
  }
}
