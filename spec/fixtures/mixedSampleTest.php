<?php

class Mixed extends PHPUnit_Framework_TestCase {
  public function testPass() {
    $this->assertTrue(true);
  }

  public function testFail() {
    $this->assertTrue(false);
  }

  public function testError() {
    throw new Exception("Broked!");
  }

  public function testSkipped() {
    $this->markTestSkipped();
  }

  public function testIncomplete() {
    $this->markTestIncomplete();
  }
}
