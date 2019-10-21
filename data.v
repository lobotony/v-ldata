module ldata

#include <stdio.h>

struct Data {
    pub mut:
    data byteptr
    size u64
}

fn (self Data) str() string {
    return 'Data{${self.data.hex()} ${self.size}}'
}

fn open(path string, mode string) *C.FILE {
	$if windows {
		return C._wfopen(path.to_wide(), mode.to_wide())
	} $else {
		cpath := path.str
		return C.fopen(cpath, mode.str) 
	}	
}

pub fn new_from_file(path string) Data { 
	mode := 'rb'
	mut fp := open(path, mode)
	if isnil(fp) {
		panic('failed to open file $path')
	}
	C.fseek(fp, 0, C.SEEK_END)
	fsize := int(C.ftell(fp))
	C.rewind(fp)
	data := malloc(fsize)
	C.fread(data, fsize, 1, fp)
	C.fclose(fp)
    result := Data{data, u64(fsize)}
    println('$path [ $fsize bytes ]')
	return result
}

pub fn (self Data) deinit() {
	unsafe {
		free(self.data)
	}
}
