#include <iostream>
#include <set>
#include <chrono>
#include <vector>
#include <string>
#include <functional>

using namespace std;
//////////////////////////////////
//profiler function
inline size_t profileFor(std::function<void()> call, const std::string& hint = ""){
    using namespace std::chrono;
    auto start = high_resolution_clock::now();
    call();
    auto diff = duration_cast<nanoseconds>(high_resolution_clock::now() - start);
    std::cout << "Time spent on <" << hint << "> is " << diff.count() << " nanoseconds" << std::endl;
    return diff.count();
};
//////////////////////////////////

template <typename T>
class MySet: public set<T>{
    public:
        using Compare = std::less<T>;
        using Allocator = std::allocator<T>;
        using Super = set<T>;

        template <typename InputIt>
        MySet(InputIt first, InputIt last, const Compare & comp = Compare(), 
                const Allocator& alloc = Allocator()) : set<int>(first, last){
            cout << tag_ << "__" << "constructor object by iterator... " << endl;
        }

        template <typename InputIt>
        void insert(InputIt first, InputIt last){
            Super::insert(first, last);
        }

        MySet& operator=(MySet && o){
            cout  << tag_ << "__" << "copy assigning with move semantics" << endl;
            Super::operator=(o);
        }

        MySet(const char* tag = "anonymous") : Super(), tag_(tag){
            cout  << tag_ << "__" << "default constructor" << endl;
        };

        ~MySet(){
            cout  << tag_ << "__" << "desctructor" << endl;
        };

    private:
        const char* tag_ = "anonymous";
};

int main()
{
    vector<int> avec = {1,2,3};
    profileFor([&avec]()->void{
        MySet<int> set("assignee");
        set = {avec.begin(), avec.end()};
    }, "Testing assigning from iterators " );

    profileFor([&avec]()->void{
        MySet<int> set("inserted");
        set.insert(avec.begin(), avec.end());
    }, "Testing insert from iterators ");
    return 0;
}
