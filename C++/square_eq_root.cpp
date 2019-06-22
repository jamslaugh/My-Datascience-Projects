#include <iostream>
#include <cmath>

int main() {
  double a,b,c;
  double root1,root2;
  
  std::cout<<"Please enter a:"<<std::endl;
  std::cin>>a;
  
  std::cout<<"Please enter b:"<<std::endl;
  std::cin>>b;
  
  std::cout<<"Please enter c:"<<std::endl;
  std::cin>>c;  
  
  root1=(-b+std::sqrt(b*b-4*a*c))/(2*a);
  
  root2=(-b-std::sqrt(b*b-4*a*c))/(2*a);

  std::cout<<"Roots are:\n root1="<<root1<<"\n while root2="<<root2;
}
