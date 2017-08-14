#include <iostream>
#include <cstdio>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <cstring>
#include <fstream>
#include <stdio.h>

int tests = 0;
int green = 0;
int red = 0;

std::string exec(const char* cmd) {
    char buffer[128];
    std::string result = "";
    std::shared_ptr<FILE> pipe(popen(cmd, "r"), pclose);
    if (!pipe) throw std::runtime_error("popen() failed!");
    while (!feof(pipe.get())) {
        if (fgets(buffer, 128, pipe.get()) != NULL)
            result += buffer;
    }
    return result;
}

std::string read_file(const char* path) {
  std::ifstream ifs(path);
  std::string content( (std::istreambuf_iterator<char>(ifs) ),
                       (std::istreambuf_iterator<char>()    ) );
  return content;
}

void test(std::string test_name, bool status, std::string message) {
  tests++;
  if (status) {
    green++;
  } else {
    std::cout << tests << ") " << "\033[2;31m" << test_name << " failed: " << message << "\033[0m\n";
    red++;
  }

}

void test(std::string test_name, bool status, std::string expected, std::string got) {
  test(test_name, status, "Expected " + expected + " but got " + got);
}

void summary() {
  std::cout << std::endl;
  std::cout << "\033[1;33m" << "Total: " << tests << "\033[0m\n";
  std::cout << "\033[1;32m" << "Green: " << green << "\033[0m\n";
  std::cout << "\033[1;31m" << "Red: " << red << "\033[0m\n";
}

void test_input1() {
  std::string output = exec("echo \"333435\" | ./bin/task1.bin");
  std::string expected = read_file("tests/files/output1");
  test("test_input1", output == expected, expected, output);
}

void test_input2() {
  std::string output = exec("echo \"33343536\" | ./bin/task1.bin");
  std::string expected = read_file("tests/files/output2");
  test("test_input2", output == expected, expected, output);
}

void test_input3() {
  std::string output = exec("echo \"4c656d6f6e\" | ./bin/task1.bin");
  std::string expected = read_file("tests/files/output3");
  test("test_input3", output == expected, expected, output);
}

void test_input4() {
  std::string output = exec("echo \"373E393D46616C7365\" | ./bin/task1.bin");
  std::string expected = read_file("tests/files/output4");
  test("test_input4", output == expected, expected, output);
}

void test_input5() {
  std::string output = exec("echo \"5468697320697320616e204571756174696f6e3a2035203e2030202626207e2f6d795f757365722f5b355d\" | ./bin/task1.bin");
  std::string expected = read_file("tests/files/output5");
  test("test_input5", output == expected, expected, output);
}

void test_input6() {
  std::string output = exec("echo \"23262425213c2c3a3b7e3f2e2a2a\" | ./bin/task1.bin");
  std::string expected = read_file("tests/files/output6");
  test("test_input6", output == expected, expected, output);
}

void test_input7() {
  std::string output = exec("echo \"4c6f72656d23697073756d26646f6c6f722873697429616d65742c2469642070657225696e766964756e742173656e73657269742e73616469707363696e67\" | ./bin/task1.bin");
  std::string expected = read_file("tests/files/output7");
  test("test_input7", output == expected, expected, output);
}

void test2_input1(std::string postfix) {
  std::string output = exec("echo \"5\n1\n\" | ./bin/task2.bin");
  std::string expected = "2" + postfix;
  test("test2_input1", output == expected, expected, output);
}

void test2_input2(std::string postfix) {
  std::string output = exec("echo \"5\n2\n\" | ./bin/task2.bin");
  std::string expected = "1" + postfix;
  test("test2_input2", output == expected, expected, output);
}

void test2_input3(std::string postfix) {
  std::string output = exec("echo \"-5\n2\n\" | ./bin/task2.bin");
  std::string expected = "x or k, or both are off range" + postfix;
  test("test2_input3", output == expected, expected, output);
}

void test2_input4(std::string postfix) {
  std::string output = exec("echo \"5\n0\n\" | ./bin/task2.bin");
  std::string expected = "x or k, or both are off range" + postfix;
  test("test2_input4", output == expected, expected, output);
}

void test2_input5(std::string postfix) {
  std::string output = exec("echo \"5\n32\n\" | ./bin/task2.bin");
  std::string expected = "x or k, or both are off range" + postfix;
  test("test2_input5", output == expected, expected, output);
}

void test2_input6(std::string postfix) {
  std::string output = exec("echo \"1000\n7\n\" | ./bin/task2.bin");
  std::string expected = "7" + postfix;
  test("test2_input6", output == expected, expected, output);
}

void test2_input7(std::string postfix) {
  std::string output = exec("echo \"1000\n31\n\" | ./bin/task2.bin");
  std::string expected = "0" + postfix;
  test("test2_input7", output == expected, expected, output);
}

int main(int argc, char** argv) {
  test_input1();
  test_input2();
  test_input3();
  test_input4();
  test_input5();
  test_input6();
  test_input7();

  std::string postfix = "\n";
  test2_input1(postfix);
  test2_input2(postfix);
  test2_input3(postfix);
  test2_input4(postfix);
  test2_input5(postfix);
  test2_input6(postfix);
  test2_input7(postfix);

  summary();
  return 0;
}
