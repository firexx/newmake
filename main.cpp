#include <iostream>
#include <iomanip>
int main(int,char *[]){
	return 0;
	unsigned char buf[] = {0x12, 0x34, 0x56, 0x78};
	unsigned char *p = buf;
	unsigned long secsSincee1900 = (*p++)<<24+(*p++)<<16+(*p++)<<8+(*p++);
	std::cout << std::hex <<  secsSincee1900 << std::endl;
}
 