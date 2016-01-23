#include <stdio.h>

struct DOS_Header 
{
    char signature[2];
    short lastsize;
    short nblocks;
    short nreloc;
    short hdrsize;
    short minalloc;
    short maxalloc;
    short ss;
    short sp;
    short checksum;
    short ip;
    short cs;
    short relocpos;
    short noverlay;
    short reserved1[4];
    short oem_id;
    short oem_info;
    short reserved2[10];
    long  e_lfanew;
};

int main(void) {
    FILE *exefile;
    struct DOS_Header header;

    exefile=fopen("DONKEYQB.EXE", "rb");
    
    if (!exefile) {
	printf("Can't read file!");
	return 1;
    }

    fread(&header, sizeof(struct DOS_Header), 1, exefile);
    
    if (!strcmp(header.signature, "MZ"))
	printf("File should start with Mark Zbikowski's initials. This is not a DOS .EXE file.");
    
    printf("Stack segment: %x\n", header.ss);
    printf("Stack pointer: %x\n", header.sp);
    printf("Instruction pointer: %x\n", header.ip);
    printf("Code segment: %x\n", header.cs);
}
