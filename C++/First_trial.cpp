#include <iostream>

int main() { 
  std::string dog_name;
  std::cout<<"Type your dog's name: ";
  std::cin>>dog_name;
  
  int dog_age;
  int early_years, later_years, human_years;
  
  //From here we take user's input.
  std::cout << "Type your dog's age (for dogs older than 2 years): ";
  std::cin>>dog_age;
  
  early_years = 21;//this variable references the first two years of a dog. 
  
  later_years=(dog_age-2)*4;//Each of the following year count as 4 human years.
  
  human_years = early_years + later_years;
  
  std::cout << "My name is "<<dog_name<<" Ruff ruff, I am "<< human_years <<" years old in human years.";
  
  return 0;
  
}
