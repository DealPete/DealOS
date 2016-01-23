 struct DOS_Header 
 {
     char signature[2] = "MZ";
     short lastsize;
     short nblocks;
     short nreloc;
     short hdrsize;
     short minalloc;
     short maxalloc;
     void *ss;
     void *sp;
     short checksum;
     void *ip;
     void *cs;
     short relocpos;
     short noverlay;
     short reserved1[4];
     short oem_id;
     short oem_info;
     short reserved2[10];
     long  e_lfanew;
 }

int main(void) {
    printf("hello, world\n");
}
