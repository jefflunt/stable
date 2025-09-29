T034: fix infinite loop in watch_all method
- update watch_all to exclude methods inherited from core classes
- add a test case to the rake task to ensure the fix works

T033: merge statefulcalculator into calculator
- add memory ivar and stateful logic to calculator class
- delete the now-redundant stateful_calculator.rb file
- remove stateful_calculator require from rake task
- clear the existing calculator.fact.example file
- add recording block to rake task for recapturing facts
- run rake task to capture new, unified facts
- remove recording block from rake task
- run rake task again to verify new facts pass
