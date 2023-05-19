FROM debian as Builder
ARG CLANG_VERSION=16.0.4

WORKDIR /
RUN apt-get update && apt-get install -y git cmake build-essential ninja-build python3
RUN git clone --recursive --depth 1 --branch llvmorg-$CLANG_VERSION https://github.com/llvm/llvm-project.git

WORKDIR /llvm-project

RUN cd clang/tools && git clone --recursive --depth 1 https://github.com/mikael-s-persson/templight.git templight && echo "add_clang_subdirectory(templight)" >> CMakeLists.txt
RUN cmake -S llvm -B build -G Ninja -DLLVM_ENABLE_PROJECTS="clang" -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build

WORKDIR /
RUN apt-get install -y libboost-all-dev
RUN git clone --recursive --depth 1 https://github.com/mikael-s-persson/templight-tools.git
WORKDIR /templight-tools
RUN mkdir build && cd build && cmake .. && make

FROM debian

COPY --from=Builder /llvm-project/build/bin/* /usr/local/bin
COPY --from=Builder /templight-tools/build/bin/* /usr/local/bin
