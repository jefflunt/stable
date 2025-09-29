T034: fix infinite loop when watching class methods
- update `watch` method to only capture `prior` state for instance methods
- add temporary recording block to rake task to verify the fix
- run rake task to confirm stack overflow is resolved
- remove temporary recording block from rake task

T033: merge statefulcalculator into calculator
- add memory ivar and stateful logic to calculator class
- delete the now-redundant stateful_calculator.rb file
- remove stateful_calculator require from rake task
- clear the existing calculator.fact.example file
- add recording block to rake task for recapturing facts
- run rake task to capture new, unified facts
- remove recording block from rake task
- run rake task again to verify new facts pass
