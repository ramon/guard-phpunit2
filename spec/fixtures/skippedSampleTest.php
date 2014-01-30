<?php

class Skipped extends PHPUnit_Framework_TestCase {
  public function testSkipped() {
    $this->markTestSkipped();
  }

  public function testIncomplete() {
    $this->markTestIncomplete();
  }

  public function testNumberThree() {
    $this->markTestSkipped();
  }
}
