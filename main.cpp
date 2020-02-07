#include <iostream>
#include <iomanip>

#include "QSmartLineEdit.h"
#include "ui_uifile.h"
#include "fw.h"
#include "fpga.h"

int main(int,char *[]){
	QSmartLineEdit sle(NULL);
	std::cout << sle.text().toStdString() << std::endl;
	std::cout << fw_size << std::endl;
	std::cout << fpga_size << std::endl;
	unsigned char buf[] = {0x12, 0x34, 0x56, 0x78};
	unsigned char *p = buf;
	unsigned long secsSincee1900 = (p[0]<<24)+(p[1]<<16)+(p[2]<<8)+p[3];
	std::cout << std::hex <<  secsSincee1900 << std::endl;
}
 