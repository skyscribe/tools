#include <iostream>
#include <vector>
#include <chrono>
#include <thread>
#include <algorithm>

using namespace std;

int main(int argc, const char *argv[])
{
    using namespace std::chrono;

    vector<thread> threads;
    for (auto i : {1,2,3,4,5,6})
        threads.emplace_back(
            [i](){
                this_thread::sleep_for(seconds(1));
                cout << "thread " << i << " execution..." << endl;
            });

    for_each(threads.begin(), threads.end(), [](thread& t){
            t.join();
            });
    return 0;
}
