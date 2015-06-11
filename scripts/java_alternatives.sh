alternatives --install /usr/bin/java java /usr/java/{{ oracle_jdk_version }}/jre/bin/java 20000 && \ 
alternatives --install /usr/bin/jar jar /usr/java/{{ oracle_jdk_version }}/bin/jar 20000 && \ 
alternatives --install /usr/bin/javac javac /usr/java/{{ oracle_jdk_version }}/bin/javac 20000 && \ 
alternatives --install /usr/bin/javaws javaws /usr/java/{{ oracle_jdk_version }}/jre/bin/javaws 20000 && \ 
alternatives --set java /usr/java/{{ oracle_jdk_version }}/jre/bin/java && \ 
alternatives --set javaws /usr/java/{{ oracle_jdk_version }}/jre/bin/javaws && \ 
alternatives --set javac /usr/java/{{ oracle_jdk_version }}/bin/javac && \ 
alternatives --set jar /usr/java/{{ oracle_jdk_version }}/bin/jar