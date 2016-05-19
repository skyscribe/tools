#include <iostream>
#include <vector>
#include <algorithm>

template <typename Cont>
void printEven(Cont c){
    std::for_each(c.begin(), c.end(), [](const auto& inst){
        if ((inst%2) == 0)
            std::cout << inst << ",";
    });
    std::cout << std::endl;
}

int main(int argc, const char *argv[])
{
    std::vector<int> avec = {1,2,3,4,5,6,6,7,7, 12, 14};
    std::vector<long> bvec = {3,4,5,6,76,7,8,89,13,13};
    
    printEven(avec); 
    printEven(bvec); 
    return 0;
}
